use("sgiec_mongo");

const contagens = {
  logs_autenticacao: db.logs_autenticacao.countDocuments(),
  eventos_acesso: db.eventos_acesso.countDocuments(),
  logs_auditoria: db.logs_auditoria.countDocuments(),
  notificacoes: db.notificacoes.countDocuments(),
  chamados_historico: db.chamados_historico.countDocuments(),
  documentos: db.documentos.countDocuments(),
  comunicados: db.comunicados.countDocuments()
};

printjson(contagens);

const total = Object.values(contagens).reduce((a,b) => a+b, 0);
print("TOTAL =", total);

// Amostras de referencias MySQL.
print("\nAmostra evento_acesso:");
printjson(db.eventos_acesso.findOne());

print("\nAmostra chamados_historico:");
printjson(db.chamados_historico.findOne());

print("\nAmostra documentos:");
printjson(db.documentos.findOne());
