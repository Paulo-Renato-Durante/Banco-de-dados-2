use("sgiec_mongo");

db.comunicados.deleteMany({});
db.chamados_historico.deleteMany({});
db.documentos.deleteMany({});
db.notificacoes.deleteMany({});
db.eventos_acesso.deleteMany({});
db.logs_auditoria.deleteMany({});
db.logs_autenticacao.deleteMany({});

print("Collections limpas.");
