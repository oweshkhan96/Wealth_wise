// src/routes/api.js
const express = require('express');
const router = express.Router();
const ExampleModel = require('../models/exam');

// Create a new example document
router.post('/example', async (req, res) => {
  try {
    const example = await ExampleModel.create(req.body);
    res.json(example);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get all example documents
router.get('/example', async (req, res) => {
  try {
    const examples = await ExampleModel.find();
    res.json(examples);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Add more routes as needed

module.exports = router;
