import express from 'express';

const app = express();
app.use(express.json());

// Rota de teste para ver se o deploy funcionou
app.get('/', (req, res) => {
  res.send('API do As-Built funcionando perfeitamente!');
});

export default app;