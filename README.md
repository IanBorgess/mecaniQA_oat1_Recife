# MecâniQA Automotive Tech — OAT 1: Fundações em Nuvem e Orquestração

Projeto acadêmico que demonstra, na prática, a conteinerização, o provisionamento de infraestrutura como código e a orquestração de um SaaS fictício chamado **MecâniQA**. A stack sobe uma API Java (Spring Boot), um banco MySQL e um cache Redis, e mostra o mesmo ambiente rodando em três camadas de maturidade crescente: **Docker Compose** (orquestração local), **Terraform** (infraestrutura como código) e **Kubernetes** (camada de controle e observabilidade com K9s).

> Trabalho da disciplina de Sistemas de Informação — Centro Universitário de Excelência (UNEX), Itabuna, 2026.
> **Autores:** Igor Sena Hagge, Ian da Silva Borges, Jonatan de Souza Ferreira, Laio Henrique Pereira da Silva.

O relatório/apresentação completo da entrega está disponível em [`mecaniQA_oat1_Recife.pdf`](./mecaniQA_oat1_Recife.pdf).

---

## Índice

- [Contexto & Desafio](#contexto--desafio)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Pré-requisitos](#pré-requisitos)
- [Como executar](#como-executar)
  - [1. Docker Compose (orquestração local)](#1-docker-compose-orquestração-local)
  - [2. Terraform (infraestrutura como código)](#2-terraform-infraestrutura-como-código)
  - [3. Kubernetes / Minikube (camada de controle)](#3-kubernetes--minikube-camada-de-controle)
- [Endpoints e credenciais](#endpoints-e-credenciais)
- [Comandos úteis](#comandos-úteis)
- [Problemas conhecidos & soluções](#problemas-conhecidos--soluções)
- [Próximos passos](#próximos-passos)
- [Referências](#referências)

---

## Contexto & Desafio

O ponto de partida é um cenário comum: uma infraestrutura local legada, com gargalos de configuração e o clássico problema de *"na minha máquina funciona"*. O objetivo da entrega é evoluir esse ambiente em quatro frentes:

1. **Empacotamento (Docker)** — build multi-stage da API Java, e containers oficiais para MySQL e Redis.
2. **Orquestração local (Docker Compose)** — comunicação via DNS interno entre serviços e persistência de dados.
3. **Infraestrutura como Código (Terraform)** — provisionamento declarativo e gestão de estado dos mesmos recursos Docker.
4. **Camada de Controle (Kubernetes + K9s)** — StatefulSets, Deployments, Services e observabilidade em tempo real.

## Arquitetura

```
                     ┌─────────────────────┐
                     │      java-api        │
                     │ Spring Boot (Java 21) │
                     └─────────┬────────────┘
                               │
                 ┌─────────────┴─────────────┐
                 │                            │
        ┌────────▼────────┐         ┌─────────▼────────┐
        │      mysql        │         │       redis        │
        │  MySQL 8.0 (dados) │         │  Redis 7-alpine   │
        │  volume persistente │         │  cache/efêmero    │
        └────────────────────┘         └────────────────────┘
```

A API expõe um endpoint simples (`GET /`) que retorna `"Hello from Docker!"`, servindo como prova de vida da stack completa (aplicação + banco + cache) em qualquer uma das três camadas de orquestração.

## Tecnologias

| Camada | Tecnologia |
|---|---|
| Linguagem / Runtime | Java 21 (Amazon Corretto) |
| Framework | Spring Boot 3.1.5 (Web, Data JPA, Data Redis) |
| Build | Gradle 8.5 (Kotlin DSL) |
| Banco de dados | MySQL 8.0 |
| Cache | Redis 7 (alpine) |
| Containerização | Docker (multi-stage build) |
| Orquestração local | Docker Compose |
| Infraestrutura como Código | Terraform (provider `kreuzwerker/docker`) |
| Orquestração de containers | Kubernetes (testado em Minikube) |
| Observabilidade | K9s |

## Estrutura do repositório

```
.
├── Dockerfile                     # Build multi-stage da API (builder + runtime alpine)
├── docker-compose.yml             # Orquestração local: api + mysql + redis
├── build.gradle.kts               # Configuração do build Spring Boot (Java 21)
├── settings.gradle.kts            # Configurações do Gradle
├── gradle.properties              # Flags de performance do Gradle (cache, paralelismo)
├── gradlew / gradlew.bat          # Gradle Wrapper
├── gradle/
│   └── wrapper/                   # gradle-wrapper.jar / .properties (Gradle 8.5)
├── src/
│   └── main/
│       ├── java/com/example/
│       │   └── Application.java   # API REST Spring Boot (endpoint "/")
│       └── resources/
│           └── application.properties  # Datasource MySQL + configuração Redis
├── terraform/
│   ├── provider.tf                # Provider Docker (named pipe, Windows)
│   ├── main.tf                    # Rede, volumes e os 3 containers
│   ├── variables.tf               # Variáveis parametrizáveis (portas, credenciais, imagens)
│   ├── outputs.tf                 # Endpoints e IDs dos recursos provisionados
│   └── terraform.tfvars           # Valores das variáveis para este ambiente
├── k8s/
│   ├── 00-namespace.yaml          # Namespace app-system
│   ├── 01-configmap.yaml          # Configurações não sensíveis
│   ├── 02-secret.yaml             # Credenciais (MySQL, Spring Datasource)
│   ├── 03-mysql.yaml              # StatefulSet + PVC (5Gi) + Service headless
│   ├── 04-redis.yaml              # Deployment + Service ClusterIP
│   └── 05-api.yaml                # Deployment (2 réplicas) + Service LoadBalancer
├── mecaniQA_oat1_Recife.pdf       # Slides/relatório da apresentação da Sprint 1
└── requirements.txt               # Checklist de entregas e comandos de referência da sprint
```

> **Nota:** apesar do nome, `requirements.txt` **não** é um arquivo de dependências Python — é o checklist de requisitos e deliverables cumpridos nesta sprint, junto com uma referência rápida de comandos.

## Pré-requisitos

Dependendo de qual camada você quiser rodar:

- [Docker](https://docs.docker.com/get-docker/) e [Docker Compose](https://docs.docker.com/compose/install/) — para a Camada 1
- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.x` — para a Camada 2
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) e [kubectl](https://kubernetes.io/docs/tasks/tools/) — para a Camada 3
- [K9s](https://k9scli.io/) (opcional) — para observabilidade do cluster Kubernetes
- JDK 21 — apenas se quiser rodar a API fora de container

## Como executar

### 1. Docker Compose (orquestração local)

Sobe a API, o MySQL e o Redis com um único comando, com DNS interno resolvendo os nomes dos serviços (`mysql`, `redis`) e volumes nomeados para persistência.

```bash
docker compose up --build
```

A API ficará disponível em `http://localhost:8081` (mapeada para a porta `8080` do container).

Para derrubar o ambiente:

```bash
docker compose down
```

### 2. Terraform (infraestrutura como código)

Provisiona a mesma stack (rede, volumes e os 3 containers) de forma declarativa via provider Docker.

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

> O `provider.tf` está configurado para o socket do Docker no Windows (`npipe:////.//pipe//docker_engine`). Em Linux/macOS, ajuste o `host` no provider para `unix:///var/run/docker.sock`.

Para destruir os recursos provisionados:

```bash
terraform destroy
```

### 3. Kubernetes / Minikube (camada de controle)

```bash
# Inicia o cluster local
minikube start --driver=docker

# Constrói a imagem da API e carrega no Minikube
docker build -t my-corretto-app:optimized .
minikube image load my-corretto-app:optimized

# Aplica todos os manifests (namespace, config, secrets, mysql, redis, api)
kubectl apply -f k8s/

# Acompanha os pods subindo
kubectl get pods -n app-system --watch
```

Como o `Service` da API é do tipo `LoadBalancer` (sem um load balancer externo real no Minikube), acesse a API via port-forward:

```bash
kubectl port-forward -n app-system svc/java-api 8080:8080
```

Para observabilidade em tempo real (pods, logs, uso de CPU/memória):

```bash
k9s
```

## Endpoints e credenciais

> ⚠️ As credenciais abaixo são valores de exemplo para ambiente de desenvolvimento/estudo, definidas em `docker-compose.yml`, `terraform.tfvars` e `k8s/02-secret.yaml`. **Não usar em produção.**

**Docker Compose**

| Serviço | Endpoint | Credenciais |
|---|---|---|
| API | `http://localhost:8081` | — |
| MySQL | `localhost:3306` | usuário `appuser` / senha `apppassword` |
| Redis | `localhost:6379` | — |

**Terraform** (portas configuráveis em `variables.tf` / `terraform.tfvars`)

| Saída (`terraform output`) | Descrição |
|---|---|
| `api_endpoint` | URL da API |
| `mysql_endpoint` | Endpoint do MySQL |
| `redis_endpoint` | Endpoint do Redis |
| `network_id` | ID da rede Docker criada |

**Kubernetes (Minikube)**

| Serviço | Endpoint interno |
|---|---|
| API | `java-api.app-system.svc.cluster.local:8080` |
| MySQL | `mysql.app-system.svc.cluster.local:3306` |
| Redis | `redis.app-system.svc.cluster.local:6379` |

## Comandos úteis

<details>
<summary><strong>Docker Compose</strong></summary>

```bash
docker compose up --pull always     # Sobe todos os serviços
docker compose down                 # Para todos os serviços
docker compose logs java-api        # Logs da API
docker ps                           # Lista containers em execução
```
</details>

<details>
<summary><strong>Terraform</strong></summary>

```bash
cd terraform/
terraform init      # Inicializa
terraform plan       # Prévia das mudanças
terraform apply       # Provisiona a infraestrutura
terraform destroy      # Remove tudo
```
</details>

<details>
<summary><strong>Kubernetes</strong></summary>

```bash
kubectl apply -f k8s/                                     # Aplica todos os manifests
kubectl get pods -n app-system                             # Lista pods
kubectl logs -n app-system <pod-name>                       # Logs de um pod
kubectl describe pod -n app-system <pod-name>                # Detalhes de um pod
kubectl port-forward -n app-system svc/java-api 8080:8080     # Acessa a API localmente
kubectl scale deployment java-api -n app-system --replicas=3   # Escala a API
```
</details>

## Problemas conhecidos & soluções

| Problema | Solução |
|---|---|
| Falha ao puxar a imagem no Kubernetes | `minikube image load my-corretto-app:optimized` |
| Kubernetes do Docker Desktop não inicia | Usar Minikube com driver Docker (`minikube start --driver=docker`) |
| Erro de `xargs` no build do Gradle dentro do Dockerfile | Instalar o pacote `findutils` no estágio de build |
| Terraform não encontra o socket do Docker no Windows | Usar `npipe:////.//pipe//docker_engine` no `provider.tf` |

## Próximos passos

- [ ] Concluir a instalação e configuração do K9s para monitoramento contínuo
- [ ] Publicar a imagem da API em um registry (Docker Hub, ECR, etc.)
- [ ] Configurar pipeline de CI/CD (GitHub Actions / GitLab CI) para a Sprint 2
- [ ] Definir storage persistente adequado para produção
- [ ] Adicionar um Ingress Controller para roteamento
- [ ] Implementar auto-scaling (HPA — Horizontal Pod Autoscaler)

## Referências

- [Documentação oficial do Docker e Docker Compose](https://docs.docker.com)
- [Documentação do Kubernetes — StatefulSets & Networking](https://kubernetes.io/docs)
- [Provider Docker no Terraform Registry](https://registry.terraform.io/providers/kreuzwerker/docker)
- Repositório oficial do projeto: [github.com/IanBorgess/mecaniQA_oat1_Recife](https://github.com/IanBorgess/mecaniQA_oat1_Recife)

---

<p align="center">Centro Universitário de Excelência · Sistemas de Informação · Itabuna, 2026</p>
