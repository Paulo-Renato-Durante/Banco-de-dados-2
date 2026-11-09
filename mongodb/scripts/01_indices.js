use("sgiec_mongo");

db.logs_autenticacao.createIndex(
  { usuario_id: 1, data_hora: -1 },
  { name: "idx_logs_auth_usuario_data" }
);

db.eventos_acesso.createIndex(
  { condominio_id: 1, tipo_evento: 1, data_hora: -1 },
  { name: "idx_eventos_condominio_tipo_data" }
);

db.logs_auditoria.createIndex(
  { condominio_id: 1, "referencia.tipo": 1, data_hora: -1 },
  { name: "idx_auditoria_condominio_entidade_data" }
);

db.notificacoes.createIndex(
  { usuario_id: 1, lida: 1, criada_em: -1 },
  { name: "idx_notificacao_usuario_lida_data" }
);

db.chamados_historico.createIndex(
  { chamado_id: 1, ultima_atualizacao: -1 },
  { name: "idx_chamado_historico_data" }
);

db.documentos.createIndex(
  { condominio_id: 1, categoria: 1, criado_em: -1 },
  { name: "idx_documentos_condominio_categoria_data" }
);

db.comunicados.createIndex(
  { condominio_id: 1, status: 1, publicado_em: -1 },
  { name: "idx_comunicados_condominio_status_data" }
);

print("Indices criados/verificados.");
