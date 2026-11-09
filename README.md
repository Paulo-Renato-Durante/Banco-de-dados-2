# SGIEC — Projeto de Banco de Dados II

Sistema de Gestão Inteligente de Edifícios e Condomínios.

## Bancos
- MySQL: dados estruturados e transacionais.
- MongoDB: históricos, documentos, notificações, logs e eventos.

## MongoDB — carga final
- logs_autenticacao: 30.000
- eventos_acesso: 25.000
- logs_auditoria: 18.000
- notificacoes: 15.000
- chamados_historico: 6.000
- documentos: 4.000
- comunicados: 2.000

Total: 100.000 documentos.

## Estrutura
- `mysql/`: scripts SQL e dump completo do banco.
- `mongodb/dados/`: JSONs finais.
- `mongodb/scripts/`: índices e verificações.
- `docs/`: requisitos, MER, modelo relacional, dicionário e relatório.

> Não publique senhas, arquivos `.env` ou credenciais reais.
