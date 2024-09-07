const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.send('<h1>Hello, World!</h1><p>This is a demo application for OriShare.</p>');
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});

