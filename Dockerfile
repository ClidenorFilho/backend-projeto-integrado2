# Usa uma versão super leve do Node.js
FROM node:20-alpine

# Cria a pasta onde o projeto vai ficar dentro do container
WORKDIR /usr/src/app

# Copia os arquivos de configuração de dependências primeiro
COPY package*.json ./
COPY prisma ./prisma/

# Instala as dependências
RUN npm install

# Gera o cliente do banco de dados (Prisma)
RUN npx prisma generate

# Copia todo o resto do código para o container
COPY . .

# Compila o TypeScript
RUN npm run build

# Expõe a porta que a nossa API vai usar
EXPOSE 3000

# Comando para rodar a aplicação em produção
CMD ["npm", "start"]