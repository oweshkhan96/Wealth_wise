const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = 3000;

const uri = "mongodb+srv://user123:ayan123@cluster0.levqkes.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

const client = new MongoClient(uri);

async function connect() {
    try {
        await client.connect();
        console.log("Connected to the MongoDB Atlas cluster");
    } catch (error) {
        console.error("Failed to connect to the MongoDB Atlas cluster", error);
    }
}
connect();

async function validateUser(username, password) {
    const user = await client.db("wealthwise").collection("users").findOne({ username, password });
    return user;
}

app.use(express.urlencoded({ extended: true }));


app.post('/login', async (req, res) => {
    const { username, password } = req.body;

    const user = await validateUser(username, password);

    if (user) {
      res.redirect('../pages/topics-detail'); 
    } else {
        res.status(401).send("Invalid username or password");
    }
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
