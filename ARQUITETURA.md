# 🏗️ Guia de Arquitetura do Backend - Projeto Integrado

**Versão:** 1.0  
**Data:** Março 2026  
**Padrão:** Arquitetura em Camadas (Layered Architecture)  
**Responsável:** Clidenor Lopes

---

## 📋 Índice

1. [Visão Geral da Arquitetura](#visão-geral)
2. [Papel das Tecnologias](#papel-das-tecnologias)
3. [Dicionário de Pastas](#dicionário-de-pastas)
4. [Fluxo da Requisição](#fluxo-da-requisição)
5. [Boas Práticas & Padrões](#boas-práticas--padrões)
6. [Diagrama Visual](#diagrama-visual)

---

## <a name="visão-geral"></a>🎯 Visão Geral da Arquitetura

Nosso backend segue a **Arquitetura em Camadas**, um padrão amplamente utilizado em aplicações web profissionais. Ela promove:

✅ **Separação de Responsabilidades** — Cada camada tem um propósito bem definido  
✅ **Testabilidade** — Fácil de testar cada componente isoladamente  
✅ **Manutenibilidade** — Código organizado e reutilizável  
✅ **Escalabilidade** — Novas funcionalidades sem impacto em código existente  

### Estrutura das 4 Camadas

```
┌─────────────────────────────────────┐
│   HTTP Request / Client / REST      │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│   CAMADA 1: Routes (Rotas)          │ ← Define endpoints
├─────────────────────────────────────┤
│   CAMADA 2: Middlewares             │ ← Intercepta requisições
├─────────────────────────────────────┤
│   CAMADA 3: Controllers (Controle)  │ ← Orquestra lógica
├─────────────────────────────────────┤
│   CAMADA 4: Services (Serviços)     │ ← Regras de negócio
├─────────────────────────────────────┤
│   CAMADA 5: Data Access (Prisma)    │ ← Banco de dados
└──────────────────┬──────────────────┘
                   │
        ┌──────────▼──────────┐
        │   PostgreSQL (DB)   │
        └─────────────────────┘
```

---

## <a name="papel-das-tecnologias"></a>🔧 Papel das Tecnologias

### **Node.js com TypeScript**

**O que é:** Ambiente JavaScript de alto desempenho para servidor + Sistema de tipagem estática

**Por quê:**
- ✨ JavaScript executado no servidor (não apenas no navegador)
- 🚀 Não-bloqueante e assíncrono → Ideal para operações I/O intensivas
- 🛡️ TypeScript garante tipos em tempo de compilação → Menos bugs em produção
- 📦 Vasto ecossistema de pacotes (npm)

**Sinergia com o projeto:** Base sólida para toda a aplicação

---

### **Express.js**

**O que é:** Framework web minimalista para criar APIs REST

**Por quê:**
- ⚡ Leve e simples — Apenas o necessário
- 🔌 Middleware pattern — Processamento central de requisições
- 🛣️ Roteamento declarativo — Define endpoints com clareza
- 🌍 Padrão de facto no ecossistema Node.js

**Como funciona no projeto:**
```typescript
// src/app.ts usa Express para:
- Parsear JSON: app.use(express.json())
- Registrar rotas: app.use('/api', routes)
- Tratar erros: app.use(errorHandler)
```

**Sinergia:** Fornece a estrutura HTTP na qual todas as outras camadas se apoiam

---

### **Prisma ORM**

**O que é:** Object-Relational Mapping — Converte dados do banco em objetos JavaScript

**Por quê:**
- 🗄️ Type-safe — Geração automática de tipos baseada no schema
- 📝 Schema declarativo — Definir estrutura do banco em um arquivo `.prisma`
- 🔄 Migrações automáticas — Versionamento do banco de dados
- 🚀 Performance — Queries otimizadas, lazy-loading de relações

**Como funciona:**
```typescript
// Exemplo prático
const user = await prisma.users.findUnique({
  where: { id: userId },
  include: { posts: true } // Carrega posts relacionados
});
// TypeScript já sabe o tipo automaticamente!
```

**Sinergia:** Desacopla a aplicação do banco, permitindo trocar PostgreSQL sem mudar código

---

### **PostgreSQL**

**O que é:** Banco de dados relacional robusto e open-source

**Por quê:**
- 📊 Relações ACID — Integridade dos dados garantida
- 🔒 Segurança nativa — Usuários, roles, permissões
- 💪 Escalável — Handles big data
- 💰 Gratuito e amplamente usado em produção

**Sinergia:** Armazena todos os dados de forma segura e eficiente

---

### **Multer & Sharp**

**Multer** — Middleware para upload de arquivos  
**Sharp** — Processamento e compressão de imagens

**Por quê:**
- 📤 Multer: Recebe files multipart/form-data
- 🖼️ Sharp: Redimensiona, converte e otimiza imagens
- 💾 Juntos: Upload eficiente com armazenamento reduzido

**Exemplo de fluxo:**
```
Usuario faz upload de foto (2MB)
  ↓
Multer intercepta e salva temporariamente
  ↓
Sharp redimensiona para 500x500px e comprime para JPEG
  ↓
Imagem otimizada (100KB) é armazenada
  ↓
Path é salvo no banco via Prisma
```

---

### **Bcrypt & JWT**

**Bcrypt** — Hash seguro para senhas  
**JWT** — Token sem estado para autenticação

**Por quê:**
- 🔐 Bcrypt: Uma via criptográfica, impossível reverter (salto adaptativo contra brute force)
- 🎫 JWT: Sem dependência de sessão no servidor, ideal para APIs distribuídas
- ⚡ Combinados: Autenticação robusta e escalável

**Fluxo típico:**
```
1. User registra com senha "123456"
   → Bcrypt gera hash: $2b$10$...
   → Armazenado no BD

2. User faz login
   → Bcrypt compara senha digitada com hash
   → Se OK, gera JWT: eyJhbGc...
   → Retorna token para client

3. Client envia requisiçoes com header: Authorization: Bearer eyJhbGc...
   → Middleware valida JWT
   → Continua se válido, rejeita se expirado/inválido
```

---

### **Docker & Docker Compose**

**Docker** — Containerização (empacotar app + dependências)  
**Docker Compose** — Orquestração multi-container

**Por quê:**
- 📦 Garante que roda igual em dev, staging e produção
- 🔗 Compose facilita conexão entre API e banco
- 🌐 Preparado para deploy em Render, AWS, etc.

**Arquivo `docker-compose.yml` define:**
```yaml
db:        # Container PostgreSQL
  - Porta 5432
  - Dados persistem em volume pgdata

api:       # Container Node.js
  - Porta 3000
  - Mount do código para hot-reload
  - DATABASE_URL apontando para o container `db`
```

---

## <a name="dicionário-de-pastas"></a>📁 Dicionário de Pastas

### **Estrutura Completa**

```
/backend
├── /prisma/                    # Banco de dados
│   ├── schema.prisma          # Definição das tabelas
│   └── /migrations/           # Histórico de alterações
│
├── /src/                       # CÓDIGO-FONTE (tudo aqui!)
│   ├── /config/               # 🔧 Configurações globais
│   │   └── prisma.config.ts   # Inicialização do Prisma
│   │
│   ├── /routes/               # 🛣️ Define endpoints HTTP
│   │   ├── index.ts           # Aggregador de rotas
│   │   ├── users.ts           # GET/POST /api/users
│   │   ├── posts.ts           # GET/POST /api/posts
│   │   └── ...
│   │
│   ├── /middlewares/          # 🔀 Interceptadores
│   │   ├── auth.ts            # Valida JWT
│   │   ├── errorHandler.ts    # Trata erros globais
│   │   ├── validation.ts      # Valida dados da request
│   │   └── ...
│   │
│   ├── /controllers/          # 👮 Orquestra a lógica
│   │   ├── UserController.ts  # Métodos: createUser, getUser, etc
│   │   ├── PostController.ts  # Métodos: createPost, getPost, etc
│   │   └── ...
│   │
│   ├── /services/             # 💼 Regras de negócio
│   │   ├── UserService.ts     # Lógica: hash senha, gerar JWT, etc
│   │   ├── PostService.ts     # Lógica: validar conteúdo, etc
│   │   ├── ImageService.ts    # Lógica: processar com Sharp
│   │   └── ...
│   │
│   ├── /utils/                # 🛠️ Funções reutilizáveis
│   │   ├── validators.ts      # Validação de email, CPF, etc
│   │   ├── helpers.ts         # Funções auxiliares gerais
│   │   ├── constants.ts       # Constantes globais (timeouts, etc)
│   │   └── ...
│   │
│   ├── app.ts                 # 🚀 Configuração Express
│   └── server.ts              # 🎬 Ponto de entrada (listen)
│
├── .env                        # Variáveis de ambiente (NÃO commit!)
├── .gitignore                  # Arquivos ignorados pelo Git
├── Dockerfile                  # Como buildar a imagem Docker
├── docker-compose.yml          # Como rodar DB + API juntos
├── package.json                # Dependências e scripts
├── tsconfig.json               # Config do TypeScript
└── ARQUITETURA.md             # Este arquivo!
```

---

### 📌 Responsabilidade de Cada Pasta

#### **/config** — Configurações Globais

**Arquivo:** `prisma.config.ts`

```typescript
// Inicializa Prisma e suas dependências
import "dotenv/config";        // Carrega .env
import { defineConfig } from "prisma/config";

export default defineConfig({
  schema: "../prisma/schema.prisma",  // Onde estão as tabelas
  datasource: {
    url: process.env.DATABASE_URL     // Conexão com PostreSQL
  }
});
```

**Por quê separado:**
- Centraliza configuração
- Fácil de swapear (ex: trocar string de conexão)
- Reutilizável em múltiplos arquivos

**Quando modificar:** Quando adicionar novas ferramentas globais (ex: Redis, Elasticsearch)

---

#### **/routes** — Define Endpoints HTTP

**Exemplo:** `routes/users.ts`

```typescript
import express from 'express';
import { UserController } from '../controllers/UserController';
import { authMiddleware } from '../middlewares/auth';

const router = express.Router();
const controller = new UserController();

// GET /api/users
router.get('/users', async (req, res) => {
  const users = await controller.getUsers();
  res.json(users);
});

// POST /api/users
router.post('/users', authMiddleware, async (req, res) => {
  const user = await controller.createUser(req.body);
  res.status(201).json(user);
});

export default router;
```

**Responsabilidades:**
- ✅ Mapear URLs para métodos do controller
- ✅ Aplicar middlewares específicos (ex: auth)
- ✅ Definir métodos HTTP (GET, POST, PUT, DELETE)
- ❌ NÃO processar lógica complexa aqui

**Quando modificar:** Toda vez que precisa de novo endpoint

---

#### **/middlewares** — Interceptadores de Requisição

Middlewares são funções que processam a requisição **antes** de chegar ao controller.

**Exemplo:** `middlewares/auth.ts`

```typescript
import jwt from 'jsonwebtoken';

export const authMiddleware = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;  // Passa user para o próximo middleware/controller
    next();              // Continua para o próximo
  } catch (e) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};
```

**Comum ter:**
- `auth.ts` — Valida JWT
- `errorHandler.ts` — Captura exceções globais
- `validation.ts` — Valida dados do corpo da request
- `logger.ts` — Log de requisições
- `cors.ts` — Controle de CORS

**Fluxo:**
```
Request → Middleware 1 → Middleware 2 → ... → Controller
```

**Quando modificar:** Quando precisa processar requisições antes de chegar no controller

---

#### **/controllers** — Orquestra a Lógica

Controller é o "maestro" — recebe a requisição, chama serviços, retorna resposta.

**Exemplo:** `controllers/UserController.ts`

```typescript
import { UserService } from '../services/UserService';

export class UserController {
  private userService = new UserService();
  
  async createUser(userData) {
    // 1. Valida dados (pode vir do middleware também)
    if (!userData.email || !userData.password) {
      throw new Error('Missing required fields');
    }
    
    // 2. Chama o serviço (delegação)
    const user = await this.userService.createUser(userData);
    
    // 3. Retorna resposta
    return user;
  }
  
  async getUser(id) {
    const user = await this.userService.getUserById(id);
    if (!user) throw new Error('User not found');
    return user;
  }
}
```

**Responsabilidades:**
- ✅ Receber dados da request (via routes/middlewares)
- ✅ Chamar serviços apropriados
- ✅ Tratar erros e retornar status HTTP correto
- ❌ NÃO implementar regras de negócio complexas (isso é do service)

**Quando modificar:** Quando adiciona novo endpoint ou altera fluxo de um existente

---

#### **/services** — Regras de Negócio

Service é onde **a lógica real acontece**. O controller apenas orquestra.

**Exemplo:** `services/UserService.ts`

```typescript
import { prisma } from '../config/prisma.config';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

export class UserService {
  async createUser(userData) {
    // Regra 1: Validar email único
    const existing = await prisma.users.findUnique({
      where: { email: userData.email }
    });
    if (existing) throw new Error('Email already in use');
    
    // Regra 2: Hash da senha
    const hashedPassword = await bcrypt.hash(userData.password, 10);
    
    // Regra 3: Criar user no banco
    const user = await prisma.users.create({
      data: {
        email: userData.email,
        password: hashedPassword,
        name: userData.name
      }
    });
    
    // Regra 4: Gerar JWT
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    return { user, token };
  }
  
  async getUserById(id) {
    return await prisma.users.findUnique({
      where: { id },
      select: { id: true, email: true, name: true } // Não retorna senha
    });
  }
}
```

**Responsabilidades:**
- ✅ Implementar regras de negócio
- ✅ Interagir com Prisma (banco de dados)
- ✅ Criptografia, géração de tokens, validações complexas
- ✅ Reutilizável por múltiplos controllers
- ❌ NÃO responder HTTP diretamente

**Quando modificar:** Toda vez que altera lógica de negócio

---

#### **/utils** — Funções Reutilizáveis

Helpers genéricos usados em múltiplos lugares.

**Exemplo:** `utils/validators.ts`

```typescript
export const isValidEmail = (email: string): boolean => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

export const isValidCPF = (cpf: string): boolean => {
  // Lógica de validação de CPF
  return cpf.length === 11;
};

export const generateSlug = (text: string): string => {
  return text.toLowerCase().replace(/\s+/g, '-');
};
```

**Par com:** `utils/constants.ts`

```typescript
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  NOT_FOUND: 404,
  INTERNAL_ERROR: 500
} as const;

export const JWT_EXPIRES_IN = '7d';
export const PASSWORD_SALT_ROUNDS = 10;
```

**Quando modificar:** Quando precisa reutilizar lógica em múltiplos serviços

---

### 📄 Arquivos Raiz Importantes

#### **app.ts** — Configuração do Express

```typescript
import express from 'express';
import userRoutes from './routes/users';
import { errorHandler } from './middlewares/errorHandler';

const app = express();

// Middlewares globais
app.use(express.json());  // Parse JSON automaticamente

// Rotas
app.use('/api', userRoutes);

// Tratamento de erros (sempre por último)
app.use(errorHandler);

export default app;
```

**Responsabilidades:**
- Inicializar Express
- Registrar middlewares globais
- Registrar rotas
- Configurar tratamento de erros

---

#### **server.ts** — Ponto de Entrada

```typescript
import app from './app';

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
});
```

**Por quê separado de app.ts:**
- `app.ts` exporta apenas a aplicação (testável)
- `server.ts` faz o listen (non-testable)
- Facilita testes unitários

---

#### **Dockerfile** — Containerização

```dockerfile
FROM node:20-alpine

WORKDIR /usr/src/app

COPY package*.json ./
COPY prisma ./prisma/

RUN npm install
RUN npx prisma generate

COPY . .

# Compila TypeScript
RUN npm run build

EXPOSE 3000

# Roda código compilado em produção
CMD ["npm", "start"]
```

**O que acontece:**
1. Usa Node.js 20 Alpine (mínimo)
2. Instala dependências
3. Gera cliente Prisma
4. Compila TypeScript
5. Roda em produção

---

#### **docker-compose.yml** — Orquestração

```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: adminpassword
      POSTGRES_DB: projetointegrado
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgresql://admin:adminpassword@db:5432/projetointegrado
    depends_on:
      - db

volumes:
  pgdata:
```

**O que faz:**
- Levanta PostgreSQL e Node.js
- Conecta os dois automaticamente
- Mantém dados persistentes em `pgdata`

**Comando para rodar:**
```bash
docker-compose up
```

---

## <a name="fluxo-da-requisição"></a>📊 Fluxo da Requisição

Vamos acompanhar uma requisição real do início ao fim!

### **Cenário**: User faz POST para criar novo artigo

```
CLIENT NAVEGADOR
     ↓
POST /api/posts
{
  "title": "Meu Artigo",
  "content": "Conteúdo aqui",
  "userId": 5
}
Authorization: Bearer eyJhbGc...
```

---

### **Passo 1️⃣: Request chega no Express (app.ts)**

```typescript
// src/app.ts
app.use(express.json());  // Parseia automaticamente

// A requisição é parseada:
{
  body: {
    title: "Meu Artigo",
    content: "Conteúdo aqui",
    userId: 5
  },
  headers: {
    authorization: "Bearer eyJhbGc..."
  }
}
```

---

### **Passo 2️⃣: Roteador encontra a rota (routes/posts.ts)**

```typescript
// src/routes/posts.ts
router.post('/posts', authMiddleware, validationMiddleware, 
  (req, res) => {
    postController.createPost(req, res);
  }
);
```

Express **identifica** que `/posts` com `POST` corresponde a esta rota.

---

### **Passo 3️⃣: Middleware de Autenticação (middlewares/auth.ts)**

```typescript
export const authMiddleware = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  
  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  req.user = {
    id: 5,
    email: 'user@email.com'
  };
  
  next();  // ✅ Autorizado, passa adiante
};
```

**O que acontece:**
- Extrai token do header
- Valida assinatura JWT
- Injeta `req.user` na requisição
- Se inválido, retorna 401 e **bloqueia aqui**

---

### **Passo 4️⃣: Middleware de Validação (middlewares/validation.ts)**

```typescript
export const validationMiddleware = (req, res, next) => {
  if (!req.body.title || req.body.title.length < 3) {
    return res.status(400).json({
      error: 'Title is required and must have at least 3 characters'
    });
  }
  
  if (!req.body.content) {
    return res.status(400).json({ error: 'Content is required' });
  }
  
  next();  // ✅ Validação passou
};
```

**O que acontece:**
- Valida dados obrigatórios
- Se inválido, retorna 400 e **bloqueia aqui**
- Caso contrário, passa adiante

---

### **Passo 5️⃣: Controller Recebe a Requisição (controllers/PostController.ts)**

```typescript
export class PostController {
  async createPost(req, res) {
    try {
      // Dados já validados pela rota e middlewares
      const postData = {
        title: req.body.title,
        content: req.body.content,
        userId: req.user.id  // Vem do middleware de auth!
      };
      
      // Delega para o serviço
      const newPost = await postService.createPost(postData);
      
      // Retorna resposta
      res.status(201).json({
        message: 'Post created successfully',
        data: newPost
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}
```

**O que acontece:**
- Recebe dados já processados
- Chama o serviço apropriado
- Trata erros
- Retorna resposta HTTP

---

### **Passo 6️⃣: Service Implementa Lógica (services/PostService.ts)**

```typescript
export class PostService {
  async createPost(postData) {
    // Regra 1: Valida que user existe
    const user = await prisma.users.findUnique({
      where: { id: postData.userId }
    });
    if (!user) throw new Error('User not found');
    
    // Regra 2: Normaliza título (maiúscula)
    const normalizedTitle = postData.title
      .trim()
      .charAt(0).toUpperCase() + postData.title.slice(1);
    
    // Regra 3: Cria slug automático
    const slug = generateSlug(normalizedTitle);
    
    // Regra 4: Valida conteúdo (máximo 10000 caracteres)
    if (postData.content.length > 10000) {
      throw new Error('Content too long');
    }
    
    // Regra 5: Cria no banco
    const post = await prisma.posts.create({
      data: {
        title: normalizedTitle,
        slug,
        content: postData.content,
        userId: postData.userId,
        createdAt: new Date(),
        status: 'published'
      }
    });
    
    return post;
  }
}
```

**O que acontece:**
- Implementa todas as regras de negócio
- Interage com Prisma (próximo passo)
- Retorna dados processados

---

### **Passo 7️⃣: Prisma Interage com Banco (Database Layer)**

```typescript
await prisma.posts.create({
  data: {
    title: 'Meu Artigo',
    slug: 'meu-artigo',
    content: 'Conteúdo aqui',
    userId: 5,
    createdAt: '2026-03-29T10:30:00Z',
    status: 'published'
  }
});
```

**O que Prisma faz:**
1. Converte para SQL:
```sql
INSERT INTO posts (title, slug, content, user_id, created_at, status)
VALUES ('Meu Artigo', 'meu-artigo', 'Conteúdo aqui', 5, NOW(), 'published');
```

2. Envia para PostgreSQL
3. Banco conforma a integridade:
   - user_id existe? ✅
   - Constraints respeitadas? ✅
4. Retorna novo post com ID gerado:
```typescript
{
  id: 42,
  title: 'Meu Artigo',
  slug: 'meu-artigo',
  content: 'Conteúdo aqui',
  userId: 5,
  createdAt: 2026-03-29T10:30:00.000Z,
  status: 'published'
}
```

---

### **Passo 8️⃣: Resposta Volta para o Cliente**

Service retorna pro Controller:
```typescript
const newPost = await postService.createPost(postData);
// newPost = { id: 42, title: 'Meu Artigo', ... }
```

Controller formata resposta HTTP:
```typescript
res.status(201).json({
  message: 'Post created successfully',
  data: {
    id: 42,
    title: 'Meu Artigo',
    slug: 'meu-artigo',
    content: 'Conteúdo aqui',
    userId: 5,
    status: 'published',
    createdAt: '2026-03-29T10:30:00Z'
  }
});
```

---

### **Fluxo Completo em Diagrama**

```
┌──────────────────────────────────────────────────────────────┐
│                     CLIENT NAVEGADOR                         │
│  POST /api/posts + Auth Header + JSON Body                  │
└─────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────┐
        │   Express (src/app.ts)          │
        │   - Parseia JSON automaticamente│
        └──────────────┬──────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────┐
        │ Routes (src/routes/posts.ts)     │
        │ - Encontra rota POST /posts      │
        └──────────────┬───────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────┐
        │ Middleware Auth (auth.ts)        │
        │ - Valida JWT                     │
        │ - Injeta req.user                │
        └──────────────┬───────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────┐
        │ Middleware Validation            │
        │ - Valida campos obrigatórios     │
        │ - Valida tipos de dados          │
        └──────────────┬───────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────┐
        │ Controller (PostController.ts)   │
        │ - Recebe dados validados         │
        │ - Chama service                  │
        └──────────────┬───────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────┐
        │ Service (PostService.ts)         │
        │ - Applica regras de negócio      │
        │ - Normaliza dados                │
        │ - Vê se user existe              │
        │ - Cria slug                      │
        └──────────────┬───────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────┐
        │ Prisma (ORM)                     │
        │ - Gera SQL                       │
        │ - Envia para PostgreSQL          │
        │ - Obtém resposta com novo ID     │
        └──────────────┬───────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────┐
        │ PostgreSQL (banco de dados)      │
        │ - INSERT INTO posts              │
        │ - Valida constraints             │
        │ - Retorna novo registro          │
        └──────────────┬───────────────────┘
                       │
                       ▼ (Resposta sobe a ladder)
        ┌──────────────────────────────────┐
        │ Service → Controller → Routes    │
        │ - Formata resposta JSON          │
        │ - Status HTTP 201 (Created)      │
        └──────────────┬───────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────┐
        │ Express envia ao navegador        │
        │ Status: 201                      │
        │ Body: { message: '...', data }   │
        └──────────────┬───────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                     CLIENT NAVEGADOR                         │
│  Recebe resposta: { id: 42, title: 'Meu Artigo', ... }      │
│  JavaScript processa e atualiza UI                          │
└──────────────────────────────────────────────────────────────┘
```

---

### **O que acontece em caso de ERRO?**

Exemplo: User tenta criar post mas não está autenticado

```
Request sem JWT
    ↓
Middleware Auth intercepta
    ↓
❌ jwt.verify() falha
    ↓
res.status(401).json({ error: 'Invalid token' })
    ↓
BLOQUEADO AQUI — nunca chega no controller
    ↓
Client recebe: HTTP 401 Unauthorized
```

---

## <a name="boas-práticas--padrões"></a>✨ Boas Práticas & Padrões

### **1. Single Responsibility Principle (SRP)**

```typescript
// ❌ ERRADO: Controller fazendo tudo
class UserController {
  async createUser(req, res) {
    // Valida email (responsabilidade 1)
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!regex.test(req.body.email)) {
      return res.status(400).json({ error: 'Invalid email' });
    }
    
    // Hash de senha (responsabilidade 2)
    const hashedPassword = await bcrypt.hash(req.body.password, 10);
    
    // Vê se email já existe (responsabilidade 3)
    const existing = await prisma.users.findUnique({
      where: { email: req.body.email }
    });
    if (existing) {
      return res.status(400).json({ error: 'Email already in use' });
    }
    
    // Cria user (responsabilidade 4)
    const user = await prisma.users.create({...});
    
    // Gera JWT (responsabilidade 5)
    const token = jwt.sign({...});
    
    res.json({ user, token });
  }
}
```

```typescript
// ✅ CORRETO: Responsabilidades separadas

// Service cuida da lógica
class UserService {
  async createUser(userData) {
    this.validateEmail(userData.email);
    const hashedPassword = await this.hashPassword(userData.password);
    const existing = await prisma.users.findUnique({...});
    if (existing) throw new Error('Email already in use');
    const user = await prisma.users.create({...});
    const token = this.generateToken(user);
    return { user, token };
  }
  
  private validateEmail(email) { /* ... */ }
  private async hashPassword(password) { /* ... */ }
  private generateToken(user) { /* ... */ }
}

// Controller apenas orquestra
class UserController {
  async createUser(req, res) {
    try {
      const result = await this.userService.createUser(req.body);
      res.status(201).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}
```

---

### **2. DRY (Don't Repeat Yourself)**

```typescript
// ❌ ERRADO: Validação de email em 3 lugares
// services/UserService.ts
const isValidEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

// services/PostService.ts
const validateEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

// middlewares/validation.ts
const checkEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

// ✅ CORRETO: Centralizar em utils
// utils/validators.ts
export const isValidEmail = (email: string): boolean => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

// Import em qualquer lugar que precisar
import { isValidEmail } from '../utils/validators';
```

---

### **3. Tratamento de Erros Consistente**

```typescript
// ❌ ERRADO: Erros sem padronização
res.json({ error: 'User not found' });        // Sem status
res.status(404).send('User not found');       // String simples
res.json({ message: 'User created' });        // Sem status
res.status(201).json({ data: user });         // Sem mensagem

// ✅ CORRETO: Padrão consistente
const apiResponse = (success, data, error = null, statusCode = 200) => {
  return {
    success,
    data,
    error,
    timestamp: new Date()
  };
};

// Sucesso
res.status(201).json(apiResponse(true, user, null, 201));

// Erro
res.status(404).json(apiResponse(false, null, 'User not found', 404));

// Middleware de tratamento global
app.use((err, req, res, next) => {
  res.status(err.statusCode || 500).json(
    apiResponse(false, null, err.message)
  );
});
```

---

### **4. Segurança: Nunca Retornar Senhas**

```typescript
// ❌ ERRADO
const user = await prisma.users.findUnique({
  where: { id: userId }
});
res.json(user);  // Inclui password_hash! Vazamento de segurança!

// ✅ CORRETO
const user = await prisma.users.findUnique({
  where: { id: userId },
  select: {
    id: true,
    email: true,
    name: true,
    // password_hash NÃO selecionado!
  }
});
res.json(user);
```

---

### **5. Usar Transações para Operações Multi-Passo**

```typescript
// ❌ ERRADO: Risco de inconsistência
const post = await prisma.posts.create({...});
const tag = await prisma.tags.create({...});
const relation = await prisma.postTags.create({...});
// E se falhar no meio? Dados inconsistentes!

// ✅ CORRETO: Tudo ou nada
const result = await prisma.$transaction(async (tx) => {
  const post = await tx.posts.create({...});
  const tag = await tx.tags.create({...});
  const relation = await tx.postTags.create({...});
  return { post, tag, relation };
});
// Se um falhar, todos são revertidos!
```

---

## <a name="diagrama-visual"></a>🎨 Diagrama Visual Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                    VISÃO DE CAMADAS                            │
└─────────────────────────────────────────────────────────────────┘

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ CAMADA 1 ━━━━━━━━━━━━━━━━━━━━━┓
┃  HTTP REQUEST (REST Clients, Navegadores, Mobile Apps)        ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
           │
           ▼
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ CAMADA 2 ━━━━━━━━━━━━━━━━━━━━━┓
┃  ROTEAMENTO (src/routes/)                                      ┃
┃  - Define endpoints: GET /posts, POST /users, etc             ┃
┃  - Mapeia URLs para métodos do controller                     ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
           │
           ▼
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ CAMADA 3 ━━━━━━━━━━━━━━━━━━━━━┓
┃  MIDDLEWARES (src/middlewares/)                                ┃
┃  - Autenticação (JWT validation)                              ┃
┃  - Validação (Schema validation)                              ┃
┃  - Error handler (Tratamento de erros)                        ┃
┃  - Logger (Log de requisições)                                ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
           │
           ▼
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ CAMADA 4 ━━━━━━━━━━━━━━━━━━━━━┓
┃  CONTROLADORES (src/controllers/)                              ┃
┃  - UserController: createUser, getUser, updateUser, etc       ┃
┃  - PostController: createPost, getPost, deletePost, etc       ┃
┃  - Orquestra requisição → Service → Response                  ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
           │
           ▼
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ CAMADA 5 ━━━━━━━━━━━━━━━━━━━━━┓
┃  SERVIÇOS (src/services/)                                      ┃
┃  - Lógica de negócio complexa                                 ┃
┃  - Validações de regras de négócio                            ┃
┃  - Operações com banco via Prisma                             ┃
┃  - Criptografia, geração de tokens                            ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
           │
           ▼
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ CAMADA 6 ━━━━━━━━━━━━━━━━━━━━━┓
┃  DATA ACCESS (Prisma ORM)                                      ┃
┃  - Gera SQL otimizado                                         ┃
┃  - Gerencia connexão com DB                                   ┃
┃  - Migrações e schema                                         ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
           │
           ▼
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ CAMADA 7 ━━━━━━━━━━━━━━━━━━━━━┓
┃  BANCO DE DADOS (PostgreSQL)                                   ┃
┃  - Tabelas, índices, constraints                              ┃
┃  - ACID compliance                                            ┃
┃  - Persistência de dados                                      ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
           │
           ▼
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  HTTP RESPONSE (JSON ao cliente)                               ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

---

### **Benefícios dessa Arquitetura**

| Benefício | Explicação |
|-----------|-----------|
| **Separação de Responsabilidades** | Cada camada tem um propósito claro |
| **Testabilidade** | Cada componente pode ser testado isoladamente |
| **Manutenibilidade** | Código organizado e fácil de compreender |
| **Escalabilidade** | Adicionar features sem quebrar existentes |
| **Reutilização** | Services usados por múltiplos controllers |
| **Segurança** | Middlewares centralizados para autenticação |
| **Performance** | Otimizações em camadas específicas |
| **Debugging** | Rastrear fluxo entre camadas |

---

## 🚀 Resumo para Apresentação

**Quando apresentar para a equipe, enfatize:**

1. **Cada pasta tem um propósito único** — Services não conhecem HTTP, Controllers não implementam regras de negócio

2. **Middlewares são gatekeepers** — Eles decidem se uma requisição continua ou é bloqueada

3. **Services são o coração da lógica** — Toda regra de negócio fica aqui, independente de quem chama

4. **Prisma desacopla o banco** — Podemos trocar PostgreSQL sem mudar código

5. **Docker garante consistência** — Dev, staging, produção rodam identicamente

6. **Fluxo claro e previsível** — Request → Route → Middlewares → Controller → Service → Prisma → DB

---


