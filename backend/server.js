const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 4000;

const dataDir = path.join(__dirname, 'data');
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir);

const db = new sqlite3.Database(path.join(dataDir, 'inventory.db'), (err) => {
  if (err) { console.error('Failed to open database:', err.message); process.exit(1); }
  console.log('Connected to SQLite database.');
});

db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      stock INTEGER NOT NULL DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `, (err) => {
    if (err) console.error('Table creation error:', err.message);
    else console.log('Products table ready.');
  });
});

app.use(express.json());

// Allow all origins manually — no cors package needed
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  next();
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/products', (req, res) => {
  db.all('SELECT * FROM products ORDER BY updated_at DESC', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

app.get('/api/products/:id', (req, res) => {
  db.get('SELECT * FROM products WHERE id = ?', [req.params.id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: 'Product not found' });
    res.json(row);
  });
});

app.post('/api/products', (req, res) => {
  const { name, stock } = req.body;
  if (!name || !name.trim()) return res.status(400).json({ error: 'Product name is required' });
  const qty = parseInt(stock) || 0;
  if (qty < 0) return res.status(400).json({ error: 'Stock cannot be negative' });
  const trimmed = name.trim();

  db.get('SELECT * FROM products WHERE name = ? COLLATE NOCASE', [trimmed], (err, existing) => {
    if (err) return res.status(500).json({ error: err.message });
    if (existing) {
      const newStock = existing.stock + qty;
      db.run('UPDATE products SET stock = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', [newStock, existing.id], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ ...existing, stock: newStock, updated_at: new Date().toISOString(), action: 'updated' });
      });
    } else {
      db.run('INSERT INTO products (name, stock) VALUES (?, ?)', [trimmed, qty], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        db.get('SELECT * FROM products WHERE id = ?', [this.lastID], (err, row) => {
          if (err) return res.status(500).json({ error: err.message });
          res.status(201).json({ ...row, action: 'created' });
        });
      });
    }
  });
});

app.patch('/api/products/:id', (req, res) => {
  const { stock } = req.body;
  if (stock === undefined || stock < 0) return res.status(400).json({ error: 'Valid stock value required' });
  db.run('UPDATE products SET stock = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', [stock, req.params.id], function(err) {
    if (err) return res.status(500).json({ error: err.message });
    if (this.changes === 0) return res.status(404).json({ error: 'Product not found' });
    db.get('SELECT * FROM products WHERE id = ?', [req.params.id], (err, row) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(row);
    });
  });
});

app.delete('/api/products/:id', (req, res) => {
  db.get('SELECT * FROM products WHERE id = ?', [req.params.id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: 'Product not found' });
    db.run('DELETE FROM products WHERE id = ?', [req.params.id], (err) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true, deleted: row });
    });
  });
});

app.listen(PORT, () => {
  console.log(`Inventory API running on http://localhost:${PORT}`);
});