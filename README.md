```
       ___         _                         _
      / _ \       | |                       | |
     / /_\ \ _   _| |_ ___  _ __   ___ _ __ | |_
     |  _  || | | | __/ _ \| '_ \ / _ \ '_ \| __|
     | | | || |_| | || (_) | | | |  __/ | | | |_
     \_| |_/ \__,_|\__\___/|_| |_|\___|_| |_|\__|

  * AUTONOMOUS SUPPORT AGENT  with  VECTOR MEMORY
    n8n  +  Ollama  +  Qdrant  +  Postgres  +  Gmail
```

# Autonomous Support Agent with Vector Memory

A **local, demo ready customer support automation** built with n8n. A customer submits an inquiry, AI classifies the intent, searches a knowledge base for answers, sends a Gmail reply, and logs everything to PostgreSQL. No cloud AI bills required.

Perfect for portfolios, client demos, and learning how agentic workflows actually work.

## What is this?

Imagine a support team that never sleeps:

1. A customer fills out a support form (or sends a simulated email)
2. AI reads the message and decides: **Billing**, **Technical Support**, or **Feature Request**
3. For technical and billing questions, an **AI agent searches your documentation** (vector memory / RAG) before answering
4. A professional email reply is sent via **Gmail**
5. The full interaction is saved in **PostgreSQL** for audit and reporting

All of this runs on your machine using **n8n**, **Ollama** (local AI), and **Qdrant** (vector search). No OpenAI API key needed.

## Use cases

| Who it's for | What you can show |
|--------------|-------------------|
| **Portfolio / job interviews** | End to end agentic AI: routing, RAG, email, and logging |
| **Client demos** | Automate support intake and knowledge retrieval with a live system |
| **Learning n8n + AI** | Real workflows: webhooks, Switch nodes, AI Agent, vector stores |
| **Internal knowledge retrieval** | Swap in your own docs and use it as an internal support bot |

**Example scenarios in the demo:**

| Scenario | What happens |
|----------|--------------|
| *"I was charged twice this month"* | Billing branch + billing policy search |
| *"My API key returns 401"* | Technical branch + AI agent searches docs |
| *"Can you add Slack integration?"* | Feature request branch + roadmap response |

## What you need

| Requirement | Notes |
|-------------|-------|
| **Docker Desktop** | [docker.com](https://www.docker.com/products/docker-desktop/) |
| **Python 3** | Usually pre installed on Mac |
| **Gmail account** | For sending demo replies (one time OAuth in n8n) |
| **First run** | ~30 to 45 min, mostly AI model download |
| **After setup** | ~5 to 10 min to start and demo again |

## Run it yourself

### Step 1: Clone the repo

```bash
git clone https://github.com/ngk1004/Autonomous-support-agent-with-vector-memory.git
cd Autonomous-support-agent-with-vector-memory
chmod +x guide help scripts/*.sh
```

### Step 2: Run the interactive guide

```
     __  __
    |  \/  | ___ _ __  _   _
    | |\/| |/ _ \ '_ \| | | |
    | |  | |  __/ | | | |_| |
    |_|  |_|\___|_| |_|\__,_|

     ./guide   interactive setup walkthrough
```

```bash
./guide
```

The guide walks you through **every step** in the terminal, like a pairing session:

1. Creates your config (`.env`, secrets, demo form)
2. Starts Docker (n8n, Postgres, Qdrant, Ollama)
3. Waits for AI models to download
4. Tells you exactly what to click in n8n
5. Helps you connect Gmail
6. Runs a proof test when you're done

Follow the prompts and press Enter when each step is complete.

### Step 3: Stuck? Run help

```
      _   _      _ _     
     | | | | ___| | | ___
     | |_| |/ _ \ | |/ _ \
     |  _  |  __/ | | (_) |
     |_| |_|\___|_|_|\___/

     ./help   interactive help center
```

```bash
./help
```

The help menu includes:

1. Getting started path
2. All commands in one place
3. Troubleshooting (pick your problem, get a fix)
4. Demo tips for showing someone
5. Live status check (what's done vs what's missing)

**Quick help topics:**

```bash
./help commands
./help troubleshoot
./help status
./help demo
```

## Prove it works

```
      ____  ____   ___  ____  _____
     |  _ \|  _ \ / _ \|  _ \| ____|
     | |_) | |_) | | | | | | |  _|
     |  __/|  __/| |_| | |_| | |___
     |_|   |_|    \___/|____/|_____|

     make prove   does the code work?
```

After finishing the guide:

```bash
make prove
```

This sends a real test inquiry and checks infrastructure, vector store, webhook, and Postgres logging.

**Show someone visually:**

```bash
make demo
```

Open http://localhost:8080, click a preset, and submit.

Then open:

1. **n8n** at http://localhost:5678 (Executions tab shows AI branching live)
2. **Gmail** for the automated reply in your inbox

```
      ____ ___  __  __ ____   ___  _   _  ____
     / ___/ _ \|  \/  |  _ \ / _ \| | | |/ ___|
     | |  | | | | |\/| | |_) | | | | | | | |
     | |__| |_| | |  | |  __/| |_| | |_| | |___
     \____\___/|_|  |_|_|    \___/ \___/ \____|

     You're ready to demo this project.
```

## How it works

```
  Customer form
       |
       v
    Webhook
       |
       v
  AI classifies intent
       |
       +--------+----------+----------+
       |        |          |          |
       v        v          v          v
   Billing   Technical  Feature    Unknown
   agent     agent      request    escalate
   + RAG     + RAG
       |        |          |
       +--------+----------+
                |
                v
          Gmail reply sent
                |
                v
        Logged to PostgreSQL
```

**Built with:** [n8n](https://n8n.io/) · [Ollama](https://ollama.com/) · [Qdrant](https://qdrant.tech/) · PostgreSQL · Gmail

## Useful commands

| Command | What it does |
|---------|--------------|
| `./guide` | Interactive setup walkthrough |
| `./help` | Interactive help menu |
| `make prove` | Test everything end to end |
| `make demo` | Start the demo web form |
| `make verify` | Health check all services |
| `make prewarm` | Warm AI models before a live demo |
| `make up` | Start Docker stack |
| `make down` | Stop Docker stack |

## Documentation

| Doc | When you need it |
|-----|------------------|
| [docs/credentials-setup.md](docs/credentials-setup.md) | Wiring n8n credentials |
| [docs/gmail-setup.md](docs/gmail-setup.md) | Gmail OAuth one time setup |
| [docs/demo-checklist.md](docs/demo-checklist.md) | Day of demo prep |

## First time vs every time after

| | First run | After setup |
|---|-----------|-------------|
| **Time** | ~30 to 45 min | ~5 to 10 min |
| **You do** | `./guide` + n8n UI steps | `make up` then `make prewarm` then `make demo` |
| **Main wait** | Ollama downloading models | None |

## License

MIT. Use freely for portfolios, demos, and learning.
