-- ============================================================
-- SGIEC - Sistema de Gestão Inteligente de Edifícios e Condomínios
-- Script DDL - Banco de Dados Relacional (MySQL)
-- ============================================================

DROP DATABASE IF EXISTS sgiec;
CREATE DATABASE sgiec CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sgiec;

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. ESTRUTURA CONDOMINIAL
-- ============================================================

CREATE TABLE administradoras (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    razao_social    VARCHAR(150) NOT NULL,
    cnpj            VARCHAR(18) NOT NULL UNIQUE,
    email           VARCHAR(120),
    telefone        VARCHAR(20),
    endereco        VARCHAR(200),
    status          ENUM('ativo','inativo') NOT NULL DEFAULT 'ativo'
) ENGINE=InnoDB;

CREATE TABLE condominios (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    administradora_id   INT UNSIGNED NOT NULL,
    nome                VARCHAR(150) NOT NULL,
    cnpj                VARCHAR(18) UNIQUE,
    tipo                ENUM('residencial','comercial','misto') NOT NULL,
    endereco            VARCHAR(200) NOT NULL,
    telefone            VARCHAR(20),
    email               VARCHAR(120),
    status              ENUM('ativo','inativo') NOT NULL DEFAULT 'ativo',
    CONSTRAINT fk_condominio_administradora FOREIGN KEY (administradora_id) REFERENCES administradoras(id)
) ENGINE=InnoDB;

CREATE TABLE blocos (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    nome            VARCHAR(50) NOT NULL,
    descricao       VARCHAR(150),
    CONSTRAINT fk_bloco_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id)
) ENGINE=InnoDB;

CREATE TABLE unidades (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    bloco_id        INT UNSIGNED NULL,
    identificacao   VARCHAR(20) NOT NULL,
    tipo            ENUM('apartamento','casa','sala_comercial','loja') NOT NULL,
    situacao        ENUM('ocupado','vago','inadimplente') NOT NULL DEFAULT 'vago',
    fracao_ideal    DECIMAL(8,5),
    area_m2         DECIMAL(8,2),
    CONSTRAINT fk_unidade_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_unidade_bloco FOREIGN KEY (bloco_id) REFERENCES blocos(id),
    CONSTRAINT uq_unidade_condominio UNIQUE (condominio_id, identificacao)
) ENGINE=InnoDB;

CREATE TABLE vagas_estacionamento (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    identificacao   VARCHAR(20) NOT NULL,
    tipo            ENUM('comum','coberta','moto') NOT NULL DEFAULT 'comum',
    unidade_id      INT UNSIGNED NULL,
    CONSTRAINT fk_vaga_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_vaga_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id)
) ENGINE=InnoDB;

CREATE TABLE areas_comuns (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    nome            VARCHAR(80) NOT NULL,
    capacidade      INT,
    descricao       VARCHAR(200),
    status          ENUM('disponivel','manutencao','inativa') NOT NULL DEFAULT 'disponivel',
    CONSTRAINT fk_area_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id)
) ENGINE=InnoDB;

-- ============================================================
-- 2. PERFIS, PERMISSÕES E USUÁRIOS
-- ============================================================

CREATE TABLE perfis (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(50) NOT NULL UNIQUE,
    descricao   VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE permissoes (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo      VARCHAR(60) NOT NULL UNIQUE,
    descricao   VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE perfil_permissoes (
    perfil_id       INT UNSIGNED NOT NULL,
    permissao_id    INT UNSIGNED NOT NULL,
    PRIMARY KEY (perfil_id, permissao_id),
    CONSTRAINT fk_pp_perfil FOREIGN KEY (perfil_id) REFERENCES perfis(id),
    CONSTRAINT fk_pp_permissao FOREIGN KEY (permissao_id) REFERENCES permissoes(id)
) ENGINE=InnoDB;

CREATE TABLE usuarios (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(120) NOT NULL,
    email           VARCHAR(120) NOT NULL UNIQUE,
    telefone        VARCHAR(20),
    senha_hash      VARCHAR(255) NOT NULL,
    status          ENUM('ativo','inativo','bloqueado') NOT NULL DEFAULT 'ativo',
    data_criacao    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE usuario_perfis (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id      INT UNSIGNED NOT NULL,
    perfil_id       INT UNSIGNED NOT NULL,
    condominio_id   INT UNSIGNED NULL,
    data_inicio     DATE NOT NULL,
    data_fim        DATE NULL,
    CONSTRAINT fk_up_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_up_perfil FOREIGN KEY (perfil_id) REFERENCES perfis(id),
    CONSTRAINT fk_up_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id)
) ENGINE=InnoDB;

-- ============================================================
-- 3. PESSOAS E VÍNCULOS
-- ============================================================

CREATE TABLE pessoas (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tipo                ENUM('fisica','juridica') NOT NULL DEFAULT 'fisica',
    nome_razaosocial    VARCHAR(150) NOT NULL,
    cpf_cnpj            VARCHAR(18) UNIQUE,
    data_nascimento     DATE NULL,
    usuario_id          INT UNSIGNED NULL,
    CONSTRAINT fk_pessoa_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

CREATE TABLE vinculos_unidade (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pessoa_id       INT UNSIGNED NOT NULL,
    unidade_id      INT UNSIGNED NOT NULL,
    tipo_vinculo    ENUM('proprietario','inquilino','morador','dependente') NOT NULL,
    responsavel_id  INT UNSIGNED NULL,
    data_inicio     DATE NOT NULL,
    data_fim        DATE NULL,
    status          ENUM('ativo','encerrado') NOT NULL DEFAULT 'ativo',
    CONSTRAINT fk_vinculo_pessoa FOREIGN KEY (pessoa_id) REFERENCES pessoas(id),
    CONSTRAINT fk_vinculo_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id),
    CONSTRAINT fk_vinculo_responsavel FOREIGN KEY (responsavel_id) REFERENCES pessoas(id)
) ENGINE=InnoDB;

CREATE TABLE contatos (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pessoa_id   INT UNSIGNED NOT NULL,
    tipo        ENUM('telefone','email','emergencia') NOT NULL,
    valor       VARCHAR(120) NOT NULL,
    descricao   VARCHAR(100),
    CONSTRAINT fk_contato_pessoa FOREIGN KEY (pessoa_id) REFERENCES pessoas(id)
) ENGINE=InnoDB;

CREATE TABLE veiculos (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pessoa_id   INT UNSIGNED NOT NULL,
    unidade_id  INT UNSIGNED NULL,
    placa       VARCHAR(8) NOT NULL UNIQUE,
    marca       VARCHAR(40),
    modelo      VARCHAR(40),
    cor         VARCHAR(20),
    vaga_id     INT UNSIGNED NULL,
    CONSTRAINT fk_veiculo_pessoa FOREIGN KEY (pessoa_id) REFERENCES pessoas(id),
    CONSTRAINT fk_veiculo_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id),
    CONSTRAINT fk_veiculo_vaga FOREIGN KEY (vaga_id) REFERENCES vagas_estacionamento(id)
) ENGINE=InnoDB;

CREATE TABLE pets (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    unidade_id  INT UNSIGNED NOT NULL,
    nome        VARCHAR(60) NOT NULL,
    especie     VARCHAR(40),
    raca        VARCHAR(60),
    observacoes VARCHAR(150),
    CONSTRAINT fk_pet_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id)
) ENGINE=InnoDB;

CREATE TABLE funcionarios (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id       INT UNSIGNED NOT NULL,
    pessoa_id           INT UNSIGNED NOT NULL,
    funcao              VARCHAR(60) NOT NULL,
    data_admissao       DATE NOT NULL,
    data_desligamento   DATE NULL,
    status              ENUM('ativo','inativo') NOT NULL DEFAULT 'ativo',
    CONSTRAINT fk_funcionario_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_funcionario_pessoa FOREIGN KEY (pessoa_id) REFERENCES pessoas(id)
) ENGINE=InnoDB;

-- ============================================================
-- 4. FINANCEIRO
-- ============================================================

CREATE TABLE contas_bancarias (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    banco           VARCHAR(60) NOT NULL,
    agencia         VARCHAR(10),
    conta           VARCHAR(20),
    tipo            ENUM('corrente','poupanca') NOT NULL DEFAULT 'corrente',
    CONSTRAINT fk_conta_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id)
) ENGINE=InnoDB;

CREATE TABLE plano_contas (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    codigo          VARCHAR(20) NOT NULL,
    descricao       VARCHAR(120) NOT NULL,
    tipo            ENUM('receita','despesa') NOT NULL,
    centro_custo    VARCHAR(60),
    CONSTRAINT fk_plano_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT uq_plano_codigo UNIQUE (condominio_id, codigo)
) ENGINE=InnoDB;

CREATE TABLE receitas (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id       INT UNSIGNED NOT NULL,
    plano_conta_id      INT UNSIGNED NOT NULL,
    conta_bancaria_id   INT UNSIGNED NOT NULL,
    competencia         DATE NOT NULL,
    valor               DECIMAL(12,2) NOT NULL CHECK (valor >= 0),
    origem              VARCHAR(100),
    status              ENUM('previsto','confirmado','cancelado') NOT NULL DEFAULT 'confirmado',
    data_lancamento     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_receita_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_receita_plano FOREIGN KEY (plano_conta_id) REFERENCES plano_contas(id),
    CONSTRAINT fk_receita_conta FOREIGN KEY (conta_bancaria_id) REFERENCES contas_bancarias(id)
) ENGINE=InnoDB;

CREATE TABLE despesas (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id       INT UNSIGNED NOT NULL,
    plano_conta_id      INT UNSIGNED NOT NULL,
    fornecedor_id       INT UNSIGNED NULL,
    conta_bancaria_id   INT UNSIGNED NOT NULL,
    competencia         DATE NOT NULL,
    valor               DECIMAL(12,2) NOT NULL CHECK (valor >= 0),
    status              ENUM('previsto','confirmado','cancelado') NOT NULL DEFAULT 'confirmado',
    data_lancamento     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_despesa_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_despesa_plano FOREIGN KEY (plano_conta_id) REFERENCES plano_contas(id),
    CONSTRAINT fk_despesa_conta FOREIGN KEY (conta_bancaria_id) REFERENCES contas_bancarias(id)
    -- fk_despesa_fornecedor adicionada após criação de "fornecedores"
) ENGINE=InnoDB;

CREATE TABLE despesas_recorrentes (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    plano_conta_id  INT UNSIGNED NOT NULL,
    valor           DECIMAL(12,2) NOT NULL,
    periodicidade   ENUM('mensal','bimestral','anual') NOT NULL DEFAULT 'mensal',
    dia_vencimento  TINYINT NOT NULL DEFAULT 10,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_desprec_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_desprec_plano FOREIGN KEY (plano_conta_id) REFERENCES plano_contas(id)
) ENGINE=InnoDB;

CREATE TABLE cobrancas (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    unidade_id      INT UNSIGNED NOT NULL,
    competencia     DATE NOT NULL,
    valor           DECIMAL(10,2) NOT NULL CHECK (valor >= 0),
    data_vencimento DATE NOT NULL,
    tipo            ENUM('ordinaria','extraordinaria','multa') NOT NULL DEFAULT 'ordinaria',
    status          ENUM('aberta','paga','vencida','cancelada') NOT NULL DEFAULT 'aberta',
    CONSTRAINT fk_cobranca_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id)
) ENGINE=InnoDB;

CREATE TABLE pagamentos (
    id                      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    cobranca_id             INT UNSIGNED NOT NULL,
    valor_pago              DECIMAL(10,2) NOT NULL,
    data_pagamento          DATETIME NOT NULL,
    forma_pagamento         ENUM('boleto','pix','dinheiro','cartao') NOT NULL DEFAULT 'pix',
    identificador_transacao VARCHAR(60),
    status                  ENUM('confirmado','estornado') NOT NULL DEFAULT 'confirmado',
    CONSTRAINT fk_pagamento_cobranca FOREIGN KEY (cobranca_id) REFERENCES cobrancas(id)
) ENGINE=InnoDB;

CREATE TABLE juros_multas (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    cobranca_id     INT UNSIGNED NOT NULL,
    tipo            ENUM('juros','multa') NOT NULL,
    valor           DECIMAL(10,2) NOT NULL,
    data_aplicacao  DATE NOT NULL,
    CONSTRAINT fk_jm_cobranca FOREIGN KEY (cobranca_id) REFERENCES cobrancas(id)
) ENGINE=InnoDB;

CREATE TABLE acordos_pagamento (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    unidade_id      INT UNSIGNED NOT NULL,
    valor_total     DECIMAL(12,2) NOT NULL,
    num_parcelas    INT NOT NULL,
    data_inicio     DATE NOT NULL,
    status          ENUM('ativo','quitado','cancelado') NOT NULL DEFAULT 'ativo',
    CONSTRAINT fk_acordo_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id)
) ENGINE=InnoDB;

CREATE TABLE parcelas_acordo (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    acordo_id       INT UNSIGNED NOT NULL,
    numero_parcela  INT NOT NULL,
    valor           DECIMAL(10,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    status          ENUM('aberta','paga','vencida') NOT NULL DEFAULT 'aberta',
    CONSTRAINT fk_parcela_acordo FOREIGN KEY (acordo_id) REFERENCES acordos_pagamento(id)
) ENGINE=InnoDB;

CREATE TABLE fundos (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    nome            VARCHAR(80) NOT NULL,
    saldo           DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_fundo_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id)
) ENGINE=InnoDB;

CREATE TABLE movimentos_fundo (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fundo_id    INT UNSIGNED NOT NULL,
    tipo        ENUM('entrada','saida') NOT NULL,
    valor       DECIMAL(12,2) NOT NULL,
    referencia  VARCHAR(150),
    data        DATE NOT NULL,
    CONSTRAINT fk_movfundo_fundo FOREIGN KEY (fundo_id) REFERENCES fundos(id)
) ENGINE=InnoDB;

CREATE TABLE orcamentos (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    plano_conta_id  INT UNSIGNED NOT NULL,
    periodo         VARCHAR(7) NOT NULL,
    valor_previsto  DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_orcamento_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_orcamento_plano FOREIGN KEY (plano_conta_id) REFERENCES plano_contas(id)
) ENGINE=InnoDB;

CREATE TABLE conciliacoes (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    conta_bancaria_id   INT UNSIGNED NOT NULL,
    data                DATE NOT NULL,
    valor               DECIMAL(12,2) NOT NULL,
    referencia_externa  VARCHAR(100),
    status              ENUM('conciliado','pendente','divergente') NOT NULL DEFAULT 'pendente',
    CONSTRAINT fk_conciliacao_conta FOREIGN KEY (conta_bancaria_id) REFERENCES contas_bancarias(id)
) ENGINE=InnoDB;

-- ============================================================
-- 5. FORNECEDORES E CONTRATOS
-- ============================================================

CREATE TABLE fornecedores (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    razao_social    VARCHAR(150) NOT NULL,
    cnpj            VARCHAR(18) NOT NULL UNIQUE,
    categoria       VARCHAR(60),
    dados_bancarios VARCHAR(150),
    telefone        VARCHAR(20),
    email           VARCHAR(120)
) ENGINE=InnoDB;

ALTER TABLE despesas
    ADD CONSTRAINT fk_despesa_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id);

CREATE TABLE contratos (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    fornecedor_id   INT UNSIGNED NOT NULL,
    objeto          VARCHAR(200) NOT NULL,
    valor           DECIMAL(12,2) NOT NULL,
    data_inicio     DATE NOT NULL,
    data_termino    DATE,
    periodicidade   ENUM('unico','mensal','anual') NOT NULL DEFAULT 'mensal',
    situacao        ENUM('ativo','encerrado','em_renovacao') NOT NULL DEFAULT 'ativo',
    responsavel_id  INT UNSIGNED NULL,
    CONSTRAINT fk_contrato_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_contrato_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id),
    CONSTRAINT fk_contrato_responsavel FOREIGN KEY (responsavel_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ============================================================
-- 6. RESERVAS
-- ============================================================

CREATE TABLE regras_reserva (
    id                      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    area_comum_id           INT UNSIGNED NOT NULL,
    duracao_min_min         INT NOT NULL DEFAULT 60,
    duracao_max_min         INT NOT NULL DEFAULT 240,
    antecedencia_min_horas  INT NOT NULL DEFAULT 24,
    capacidade              INT,
    intervalo_min           INT NOT NULL DEFAULT 0,
    taxa                    DECIMAL(8,2) DEFAULT 0,
    CONSTRAINT fk_regra_area FOREIGN KEY (area_comum_id) REFERENCES areas_comuns(id)
) ENGINE=InnoDB;

CREATE TABLE reservas (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    area_comum_id   INT UNSIGNED NOT NULL,
    unidade_id      INT UNSIGNED NOT NULL,
    solicitante_id  INT UNSIGNED NOT NULL,
    data            DATE NOT NULL,
    horario_inicio  TIME NOT NULL,
    horario_fim     TIME NOT NULL,
    status          ENUM('confirmada','cancelada','concluida') NOT NULL DEFAULT 'confirmada',
    CONSTRAINT fk_reserva_area FOREIGN KEY (area_comum_id) REFERENCES areas_comuns(id),
    CONSTRAINT fk_reserva_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id),
    CONSTRAINT fk_reserva_solicitante FOREIGN KEY (solicitante_id) REFERENCES pessoas(id),
    CONSTRAINT uq_reserva_area_horario UNIQUE (area_comum_id, data, horario_inicio)
) ENGINE=InnoDB;

-- ============================================================
-- 7. OPERAÇÃO (CHAMADOS, OCORRÊNCIAS, MANUTENÇÃO)
-- ============================================================

CREATE TABLE chamados (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id       INT UNSIGNED NOT NULL,
    unidade_id          INT UNSIGNED NULL,
    solicitante_id      INT UNSIGNED NOT NULL,
    categoria           VARCHAR(60) NOT NULL,
    responsavel_id      INT UNSIGNED NULL,
    prioridade          ENUM('baixa','media','alta','urgente') NOT NULL DEFAULT 'media',
    status              ENUM('aberto','em_andamento','encerrado','cancelado','reaberto') NOT NULL DEFAULT 'aberto',
    data_abertura       DATETIME NOT NULL,
    data_encerramento   DATETIME NULL,
    CONSTRAINT fk_chamado_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_chamado_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id),
    CONSTRAINT fk_chamado_solicitante FOREIGN KEY (solicitante_id) REFERENCES pessoas(id),
    CONSTRAINT fk_chamado_responsavel FOREIGN KEY (responsavel_id) REFERENCES funcionarios(id)
) ENGINE=InnoDB;

CREATE TABLE ocorrencias (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    categoria       VARCHAR(60) NOT NULL,
    data            DATETIME NOT NULL,
    unidade_id      INT UNSIGNED NULL,
    area_comum_id   INT UNSIGNED NULL,
    responsavel_id  INT UNSIGNED NULL,
    status          ENUM('aberta','em_analise','encerrada') NOT NULL DEFAULT 'aberta',
    CONSTRAINT fk_ocorrencia_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_ocorrencia_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id),
    CONSTRAINT fk_ocorrencia_area FOREIGN KEY (area_comum_id) REFERENCES areas_comuns(id),
    CONSTRAINT fk_ocorrencia_responsavel FOREIGN KEY (responsavel_id) REFERENCES funcionarios(id)
) ENGINE=InnoDB;

CREATE TABLE equipamentos (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    nome            VARCHAR(80) NOT NULL,
    tipo            VARCHAR(60),
    localizacao     VARCHAR(100),
    data_instalacao DATE,
    status          ENUM('ativo','manutencao','inativo') NOT NULL DEFAULT 'ativo',
    CONSTRAINT fk_equipamento_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id)
) ENGINE=InnoDB;

CREATE TABLE planos_manutencao (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    equipamento_id      INT UNSIGNED NOT NULL,
    periodicidade       ENUM('mensal','trimestral','semestral','anual') NOT NULL DEFAULT 'mensal',
    responsavel_id      INT UNSIGNED NULL,
    proxima_execucao    DATE,
    CONSTRAINT fk_planomanut_equipamento FOREIGN KEY (equipamento_id) REFERENCES equipamentos(id),
    CONSTRAINT fk_planomanut_responsavel FOREIGN KEY (responsavel_id) REFERENCES funcionarios(id)
) ENGINE=InnoDB;

CREATE TABLE ordens_manutencao (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    equipamento_id      INT UNSIGNED NULL,
    area_comum_id       INT UNSIGNED NULL,
    tipo                ENUM('preventiva','corretiva') NOT NULL DEFAULT 'corretiva',
    prioridade          ENUM('baixa','media','alta','urgente') NOT NULL DEFAULT 'media',
    responsavel_id      INT UNSIGNED NULL,
    fornecedor_id       INT UNSIGNED NULL,
    data_abertura       DATETIME NOT NULL,
    data_execucao       DATETIME NULL,
    status              ENUM('aberta','em_andamento','concluida','cancelada') NOT NULL DEFAULT 'aberta',
    custo_previsto      DECIMAL(10,2),
    custo_realizado     DECIMAL(10,2),
    CONSTRAINT fk_ordem_equipamento FOREIGN KEY (equipamento_id) REFERENCES equipamentos(id),
    CONSTRAINT fk_ordem_area FOREIGN KEY (area_comum_id) REFERENCES areas_comuns(id),
    CONSTRAINT fk_ordem_responsavel FOREIGN KEY (responsavel_id) REFERENCES funcionarios(id),
    CONSTRAINT fk_ordem_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id)
) ENGINE=InnoDB;

-- ============================================================
-- 8. GOVERNANÇA
-- ============================================================

CREATE TABLE assembleias (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    tipo            ENUM('ordinaria','extraordinaria') NOT NULL,
    data            DATE NOT NULL,
    horario         TIME NOT NULL,
    local_modalidade VARCHAR(100),
    situacao        ENUM('convocada','em_andamento','encerrada','cancelada') NOT NULL DEFAULT 'convocada',
    CONSTRAINT fk_assembleia_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id)
) ENGINE=InnoDB;

CREATE TABLE pautas (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assembleia_id   INT UNSIGNED NOT NULL,
    descricao       VARCHAR(200) NOT NULL,
    ordem           INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_pauta_assembleia FOREIGN KEY (assembleia_id) REFERENCES assembleias(id)
) ENGINE=InnoDB;

CREATE TABLE participantes_assembleia (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assembleia_id   INT UNSIGNED NOT NULL,
    pessoa_id       INT UNSIGNED NOT NULL,
    presente        BOOLEAN NOT NULL DEFAULT FALSE,
    hora_registro   DATETIME,
    CONSTRAINT fk_participante_assembleia FOREIGN KEY (assembleia_id) REFERENCES assembleias(id),
    CONSTRAINT fk_participante_pessoa FOREIGN KEY (pessoa_id) REFERENCES pessoas(id)
) ENGINE=InnoDB;

CREATE TABLE votacoes (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pauta_id            INT UNSIGNED NOT NULL,
    data_inicio         DATETIME NOT NULL,
    data_fim            DATETIME NOT NULL,
    regra_elegibilidade VARCHAR(150),
    CONSTRAINT fk_votacao_pauta FOREIGN KEY (pauta_id) REFERENCES pautas(id)
) ENGINE=InnoDB;

CREATE TABLE alternativas_voto (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    votacao_id  INT UNSIGNED NOT NULL,
    descricao   VARCHAR(150) NOT NULL,
    peso        DECIMAL(5,2) NOT NULL DEFAULT 1,
    CONSTRAINT fk_alternativa_votacao FOREIGN KEY (votacao_id) REFERENCES votacoes(id)
) ENGINE=InnoDB;

CREATE TABLE votos (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    votacao_id      INT UNSIGNED NOT NULL,
    alternativa_id  INT UNSIGNED NOT NULL,
    pessoa_id       INT UNSIGNED NOT NULL,
    data_hora       DATETIME NOT NULL,
    CONSTRAINT fk_voto_votacao FOREIGN KEY (votacao_id) REFERENCES votacoes(id),
    CONSTRAINT fk_voto_alternativa FOREIGN KEY (alternativa_id) REFERENCES alternativas_voto(id),
    CONSTRAINT fk_voto_pessoa FOREIGN KEY (pessoa_id) REFERENCES pessoas(id),
    CONSTRAINT uq_voto_unico UNIQUE (votacao_id, pessoa_id)
) ENGINE=InnoDB;

CREATE TABLE enquetes (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    pergunta        VARCHAR(200) NOT NULL,
    data_criacao    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          ENUM('aberta','encerrada') NOT NULL DEFAULT 'aberta',
    CONSTRAINT fk_enquete_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id)
) ENGINE=InnoDB;

CREATE TABLE opcoes_enquete (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    enquete_id  INT UNSIGNED NOT NULL,
    descricao   VARCHAR(150) NOT NULL,
    CONSTRAINT fk_opcao_enquete FOREIGN KEY (enquete_id) REFERENCES enquetes(id)
) ENGINE=InnoDB;

CREATE TABLE respostas_enquete (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    opcao_id    INT UNSIGNED NOT NULL,
    pessoa_id   INT UNSIGNED NOT NULL,
    data_hora   DATETIME NOT NULL,
    CONSTRAINT fk_resposta_opcao FOREIGN KEY (opcao_id) REFERENCES opcoes_enquete(id),
    CONSTRAINT fk_resposta_pessoa FOREIGN KEY (pessoa_id) REFERENCES pessoas(id)
) ENGINE=InnoDB;

-- ============================================================
-- 9. PORTARIA
-- ============================================================

CREATE TABLE visitantes (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(120) NOT NULL,
    documento   VARCHAR(20),
    telefone    VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE autorizacoes_acesso (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    unidade_id      INT UNSIGNED NOT NULL,
    visitante_id    INT UNSIGNED NULL,
    prestador_id    INT UNSIGNED NULL,
    responsavel_id  INT UNSIGNED NOT NULL,
    tipo            ENUM('unica','recorrente') NOT NULL DEFAULT 'unica',
    data_inicio     DATETIME NOT NULL,
    data_fim        DATETIME NULL,
    status          ENUM('valida','expirada','cancelada') NOT NULL DEFAULT 'valida',
    CONSTRAINT fk_autorizacao_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id),
    CONSTRAINT fk_autorizacao_visitante FOREIGN KEY (visitante_id) REFERENCES visitantes(id),
    CONSTRAINT fk_autorizacao_prestador FOREIGN KEY (prestador_id) REFERENCES fornecedores(id),
    CONSTRAINT fk_autorizacao_responsavel FOREIGN KEY (responsavel_id) REFERENCES pessoas(id)
) ENGINE=InnoDB;

CREATE TABLE encomendas (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    unidade_id      INT UNSIGNED NOT NULL,
    remetente       VARCHAR(150),
    transportadora  VARCHAR(100),
    data_recebimento DATETIME NOT NULL,
    data_retirada   DATETIME NULL,
    status          ENUM('aguardando','retirada') NOT NULL DEFAULT 'aguardando',
    CONSTRAINT fk_encomenda_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id)
) ENGINE=InnoDB;

-- ============================================================
-- 10. MEDIÇÕES
-- ============================================================

CREATE TABLE medidores (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    condominio_id   INT UNSIGNED NOT NULL,
    unidade_id      INT UNSIGNED NULL,
    area_comum_id   INT UNSIGNED NULL,
    tipo            ENUM('agua','gas','energia') NOT NULL,
    CONSTRAINT fk_medidor_condominio FOREIGN KEY (condominio_id) REFERENCES condominios(id),
    CONSTRAINT fk_medidor_unidade FOREIGN KEY (unidade_id) REFERENCES unidades(id),
    CONSTRAINT fk_medidor_area FOREIGN KEY (area_comum_id) REFERENCES areas_comuns(id)
) ENGINE=InnoDB;

CREATE TABLE leituras (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    medidor_id          INT UNSIGNED NOT NULL,
    periodo             VARCHAR(7) NOT NULL,
    leitura_anterior    DECIMAL(10,2),
    leitura_atual       DECIMAL(10,2),
    consumo_calculado   DECIMAL(10,2),
    origem              ENUM('manual','importado') NOT NULL DEFAULT 'manual',
    data_leitura        DATE NOT NULL,
    CONSTRAINT fk_leitura_medidor FOREIGN KEY (medidor_id) REFERENCES medidores(id)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- ÍNDICES ADICIONAIS (além dos gerados automaticamente por PK/UNIQUE)
-- ============================================================

CREATE INDEX idx_unidades_situacao ON unidades(situacao);
CREATE INDEX idx_cobrancas_status_vencimento ON cobrancas(status, data_vencimento);
CREATE INDEX idx_pagamentos_data ON pagamentos(data_pagamento);
CREATE INDEX idx_despesas_competencia ON despesas(competencia);
CREATE INDEX idx_chamados_status ON chamados(status);
CREATE INDEX idx_chamados_condominio_categoria ON chamados(condominio_id, categoria);
CREATE INDEX idx_reservas_data ON reservas(data);
CREATE INDEX idx_leituras_periodo ON leituras(periodo);
CREATE INDEX idx_vinculos_unidade_status ON vinculos_unidade(unidade_id, status);
CREATE INDEX idx_ordens_manutencao_status ON ordens_manutencao(status);
