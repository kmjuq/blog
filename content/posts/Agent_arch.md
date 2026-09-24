---
title: "Agent 技术脉络"
date: 2025-10-22T09:14:47+08:00
draft: true
tags: ["大模型"]
---

## Agent 技术脉络
### 模型接入
### context
#### Memory
#### Skill
#### RAG
### Tools
#### Hosted tools
#### Function calling
#### MCP
openai 的 sdk 支持直接定义 MCP Server 数据。而不用在 Agent 中定义 MCP Client。
如果产品部署在公网上，又想访问内网的 MCP Server ，openai 有一套Secure MCP Tunnel 标准，可了解。
### 运行时与编排
#### loop
#### schedule
### 工程
#### 执行隔离：Sandbox
#### 状态与恢复：Checkpoint
#### 人机协同：HITL
#### 可观测性：Observability
#### 评估：Evaluation
#### 安全与合规：Guardrails




缺点：
- 工程碎片化
  
`Funcation Calling` 是大模型API内部设计的功能，当该概念面世时，未形成相关标准，各个大模型厂商都是各自设计实现的。
- 

### MCP

缺点：
- 安全问题

MCP协议的接口授权问题，模型无法感知用户内容是否包含特殊内容使模型调用其他工具，导致非预期结果。

- 大规模应用问题

当MCP服务或工具的数量过多时，模型可能无法选择与目标关联度最高的工具。过多的工具会导致Token资源的浪费，而且在多轮会话中，工具列表会被重复传递。