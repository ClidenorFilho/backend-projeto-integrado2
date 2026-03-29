import app from './app.js';

// O Render injeta a porta automaticamente na variável process.env.PORT
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});