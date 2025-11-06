const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// serve static files from /public
app.use(express.static(path.join(__dirname, 'public')));

// small quotes for /quote endpoint
const quotes = [
  "Code is like humor. When you have to explain it, it's bad.",
  "First, solve the problem. Then, write the code.",
  "It's not a bug – it's an undocumented feature.",
  "Before software can be reusable it first has to be usable.",
  "Experience is the name everyone gives to their mistakes."
];

app.get('/quote', (_req, res) => {
  const q = quotes[Math.floor(Math.random() * quotes.length)];
  res.json({ quote: q });
});

app.listen(PORT, () => {
  console.log(`🎯 Server is running on port ${PORT}`);
});
