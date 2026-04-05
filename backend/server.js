const express = require('express');
const { Pool } = require('pg');
require('dotenv').config();


const app = express();
const PORT = process.env.PORT || 4000;

// ─── PostgreSQL ───────────────────────────────────────────────────────────────

const db = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

db.connect((err) => {
  if (err) { console.error('Failed to connect to PostgreSQL:', process.env.DATABASE_URL); process.exit(1); }
  console.log('Connected to PostgreSQL database.');
});

db.query(`
  CREATE TABLE IF NOT EXISTS products (
    id         SERIAL PRIMARY KEY,
    name       TEXT        NOT NULL UNIQUE,
    stock      INTEGER     NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
  )
`).then(() => console.log('Products table ready.'))
  .catch((err) => console.error('Table creation error:', err.message));

// ─── Middleware ───────────────────────────────────────────────────────────────

app.use(express.json());

app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  next();
});

// ─── Routes ───────────────────────────────────────────────────────────────────

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/products', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM products ORDER BY updated_at DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/products/:id', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM products WHERE id = $1', [req.params.id]);
    if (!rows[0]) return res.status(404).json({ error: 'Product not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/products', async (req, res) => {
  const { name, stock } = req.body;
  if (!name || !name.trim()) return res.status(400).json({ error: 'Product name is required' });
  const qty = parseInt(stock) || 0;
  if (qty < 0) return res.status(400).json({ error: 'Stock cannot be negative' });
  const trimmed = name.trim();

  try {
    const existing = await db.query(
      'SELECT * FROM products WHERE LOWER(name) = LOWER($1)',
      [trimmed]
    );

    let result;
    if (existing.rows[0]) {
      const newStock = existing.rows[0].stock + qty;
      const { rows } = await db.query(
        'UPDATE products SET stock = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
        [newStock, existing.rows[0].id]
      );
      result = { ...rows[0], action: 'updated' };
    } else {
      const { rows } = await db.query(
        'INSERT INTO products (name, stock) VALUES ($1, $2) RETURNING *',
        [trimmed, qty]
      );
      result = { ...rows[0], action: 'created' };
    }

    res.status(result.action === 'created' ? 201 : 200).json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.patch('/api/products/:id', async (req, res) => {
  const { stock } = req.body;
  if (stock === undefined || stock < 0) return res.status(400).json({ error: 'Valid stock value required' });

  try {
    const { rows } = await db.query(
      'UPDATE products SET stock = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
      [stock, req.params.id]
    );
    if (!rows[0]) return res.status(404).json({ error: 'Product not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/products/:id', async (req, res) => {
  try {
    const { rows } = await db.query(
      'DELETE FROM products WHERE id = $1 RETURNING *',
      [req.params.id]
    );
    if (!rows[0]) return res.status(404).json({ error: 'Product not found' });
    res.json({ success: true, deleted: rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── Start ────────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`Inventory API running on http://${process.env.BACK_END_API}:${PORT}`);
});