// src/models/ExampleModel.js
const mongoose = require('mongoose');

const exampleSchema = new mongoose.Schema({
  // Define your schema fields here
});

const ExampleModel = mongoose.model('Example', exampleSchema);

module.exports = ExampleModel;
