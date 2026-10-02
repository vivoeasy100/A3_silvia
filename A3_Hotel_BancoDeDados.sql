-- ============================================================
-- A3 - PROJETO DE BANCO DE DADOS
-- Centro Universitário UNA - Barreiro
-- Tema: Sistema de Gerenciamento de Hotel - "Hotel Bela Vista"
-- Prof: Alexandre e Silvia
-- Grupo: Esdras Andrade, Pedro Antônio, Lucas Miranda,
--        Gabriel Ferreira, Fernando Almeida, Cauã Mendes, Caio Duraes
-- ============================================================

-- ============================================================
-- DDL - DATA DEFINITION LANGUAGE
-- ============================================================

-- Tabela: HOSPEDE
CREATE TABLE hospede (
    id_hospede      SERIAL PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    cpf             CHAR(11)     NOT NULL UNIQUE,
    email           VARCHAR(100) NOT NULL UNIQUE,
    telefone        VARCHAR(20),
    data_nascimento DATE,
    logradouro      VARCHAR(150),
    cidade          VARCHAR(80),
    estado          CHAR(2),
    cep             CHAR(8),
    criado_em       TIMESTAMP DEFAULT NOW()
);

-- Tabela: TIPO_QUARTO
CREATE TABLE tipo_quarto (
    id_tipo      SERIAL PRIMARY KEY,
    nome         VARCHAR(50)   NOT NULL,
    descricao    TEXT,
    capacidade   INT           NOT NULL CHECK (capacidade > 0),
    preco_diaria NUMERIC(10,2) NOT NULL CHECK (preco_diaria > 0)
);

-- Tabela: QUARTO
CREATE TABLE quarto (
    id_quarto SERIAL PRIMARY KEY,
    numero    VARCHAR(10)  NOT NULL UNIQUE,
    id_tipo   INT          NOT NULL REFERENCES tipo_quarto(id_tipo),
    andar     INT          NOT NULL,
    status    VARCHAR(20)  NOT NULL DEFAULT 'disponivel'
              CHECK (status IN ('disponivel','ocupado','manutencao','reservado'))
);

-- Tabela: FUNCIONARIO
CREATE TABLE funcionario (
    id_funcionario SERIAL PRIMARY KEY,
    nome           VARCHAR(100)  NOT NULL,
    cpf            CHAR(11)      NOT NULL UNIQUE,
    cargo          VARCHAR(60)   NOT NULL,
    salario        NUMERIC(10,2) NOT NULL CHECK (salario > 0),
    data_admissao  DATE          NOT NULL,
    telefone       VARCHAR(20),
    ativo          BOOLEAN DEFAULT TRUE
);

-- Tabela: RESERVA
CREATE TABLE reserva (
    id_reserva     SERIAL PRIMARY KEY,
    id_hospede     INT NOT NULL REFERENCES hospede(id_hospede),
    id_quarto      INT NOT NULL REFERENCES quarto(id_quarto),
    id_funcionario INT REFERENCES funcionario(id_funcionario),
    data_reserva   TIMESTAMP    NOT NULL DEFAULT NOW(),
    data_checkin   DATE         NOT NULL,
    data_checkout  DATE         NOT NULL,
    status         VARCHAR(20)  NOT NULL DEFAULT 'confirmada'
                   CHECK (status IN ('pendente','confirmada','em_andamento','concluida','cancelada')),
    valor_total    NUMERIC(10,2),
    observacoes    TEXT,
    CONSTRAINT chk_datas CHECK (data_checkout > data_checkin)
);

-- Tabela: SERVICO
CREATE TABLE servico (
    id_servico SERIAL PRIMARY KEY,
    nome       VARCHAR(80)   NOT NULL,
    descricao  TEXT,
    preco      NUMERIC(10,2) NOT NULL CHECK (preco >= 0),
    ativo      BOOLEAN DEFAULT TRUE
);

-- Tabela associativa: RESERVA_SERVICO (N:M entre reserva e servico)
CREATE TABLE reserva_servico (
    id_reserva_servico SERIAL PRIMARY KEY,
    id_reserva         INT           NOT NULL REFERENCES reserva(id_reserva),
    id_servico         INT           NOT NULL REFERENCES servico(id_servico),
    quantidade         INT           NOT NULL DEFAULT 1 CHECK (quantidade > 0),
    data_solicitacao   TIMESTAMP     NOT NULL DEFAULT NOW(),
    valor_unitario     NUMERIC(10,2) NOT NULL
);

-- Tabela: PAGAMENTO
CREATE TABLE pagamento (
    id_pagamento    SERIAL PRIMARY KEY,
    id_reserva      INT           NOT NULL REFERENCES reserva(id_reserva),
    valor           NUMERIC(10,2) NOT NULL CHECK (valor > 0),
    data_pagamento  TIMESTAMP     NOT NULL DEFAULT NOW(),
    forma_pagamento VARCHAR(30)   NOT NULL
                    CHECK (forma_pagamento IN ('dinheiro','cartao_credito','cartao_debito','pix','transferencia')),
    status          VARCHAR(20)   NOT NULL DEFAULT 'aprovado'
                    CHECK (status IN ('pendente','aprovado','recusado','estornado'))
);

-- Tabela: NOTA_FISCAL
CREATE TABLE nota_fiscal (
    id_nota      SERIAL PRIMARY KEY,
    id_pagamento INT           NOT NULL UNIQUE REFERENCES pagamento(id_pagamento),
    numero_nota  VARCHAR(20)   NOT NULL UNIQUE,
    data_emissao TIMESTAMP     NOT NULL DEFAULT NOW(),
    valor_total  NUMERIC(10,2) NOT NULL,
    descricao    TEXT
);

-- ============================================================
-- DML - DATA MANIPULATION LANGUAGE  (INSERTs)
-- ============================================================

-- TIPOS DE QUARTO
INSERT INTO tipo_quarto (nome, descricao, capacidade, preco_diaria) VALUES
('Standard',      'Quarto padrão com cama de casal e ar-condicionado.',      2, 180.00),
('Standard Twin', 'Quarto padrão com duas camas de solteiro.',               2, 190.00),
('Luxo',          'Quarto luxo com cama king size e jacuzzi.',               2, 320.00),
('Suite Master',  'Suíte com sala de estar e vista panorâmica.',             3, 520.00),
('Familiar',      'Quarto amplo com cama de casal e beliche.',               4, 280.00);

-- QUARTOS
INSERT INTO quarto (numero, id_tipo, andar, status) VALUES
('101', 1, 1, 'disponivel'),
('102', 1, 1, 'disponivel'),
('103', 2, 1, 'disponivel'),
('201', 3, 2, 'disponivel'),
('202', 3, 2, 'manutencao'),
('203', 5, 2, 'disponivel'),
('301', 4, 3, 'disponivel'),
('302', 4, 3, 'reservado'),
('104', 1, 1, 'ocupado'),
('204', 3, 2, 'disponivel');

-- FUNCIONÁRIOS
INSERT INTO funcionario (nome, cpf, cargo, salario, data_admissao, telefone) VALUES
('Ana Beatriz Costa',   '11122233300', 'Recepcionista', 2200.00, '2022-03-01', '31991110001'),
('Ricardo Souza Lima',  '22233344411', 'Gerente Geral',  5500.00, '2020-06-15', '31991110002'),
('Claudia Mendes',      '33344455522', 'Camareira',      1800.00, '2023-01-10', '31991110003'),
('Thiago Nascimento',   '44455566633', 'Recepcionista',  2200.00, '2021-09-20', '31991110004'),
('Juliana Faria',       '55566677744', 'Concierge',      2600.00, '2022-07-05', '31991110005');

-- HÓSPEDES
INSERT INTO hospede (nome, cpf, email, telefone, data_nascimento, logradouro, cidade, estado, cep) VALUES
('Carlos Eduardo Alves', '98765432100', 'carlos.alves@email.com',   '31988880001', '1985-04-12', 'Rua das Flores, 45',     'Belo Horizonte', 'MG', '30000001'),
('Mariana Oliveira',     '87654321099', 'mariana.oliveira@email.com','31988880002', '1992-08-23', 'Av. Brasil, 200',        'Sao Paulo',      'SP', '01000001'),
('Joao Pedro Santos',    '76543210988', 'joao.santos@email.com',    '31988880003', '1978-11-05', 'Rua XV de Novembro, 10', 'Curitiba',       'PR', '80000001'),
('Fernanda Lima',        '65432109877', 'fernanda.lima@email.com',  '31988880004', '1990-02-14', 'Rua Dom Pedro II, 88',   'Rio de Janeiro', 'RJ', '20000001'),
('Roberto Carvalho',     '54321098766', 'roberto.carvalho@email.com','11988880005', '1982-06-30', 'Av. Paulista, 1000',     'Sao Paulo',      'SP', '01310001'),
('Luciana Teixeira',     '43210987655', 'luciana.teixeira@email.com','31988880006', '1995-12-01', 'Rua Goias, 55',          'Uberlandia',     'MG', '38400001'),
('Andre Moura',          '32109876544', 'andre.moura@email.com',    '21988880007', '1988-03-25', 'Av. Atlantica, 300',     'Rio de Janeiro', 'RJ', '22010001'),
('Patricia Nunes',       '21098765433', 'patricia.nunes@email.com', '31988880008', '2000-07-19', 'Rua Pernambuco, 70',     'Belo Horizonte', 'MG', '30130001');

-- RESERVAS
INSERT INTO reserva (id_hospede, id_quarto, id_funcionario, data_checkin, data_checkout, status, valor_total) VALUES
(1, 1, 1, '2026-09-10', '2026-09-13', 'concluida',    590.00),
(2, 4, 4, '2026-09-15', '2026-09-18', 'concluida',   1120.00),
(3, 7, 1, '2026-09-20', '2026-09-23', 'concluida',   1640.00),
(4, 3, 4, '2026-09-22', '2026-09-24', 'concluida',    430.00),
(5, 2, 1, '2026-10-01', '2026-10-05', 'em_andamento', 720.00),
(6, 6, 1, '2026-10-03', '2026-10-07', 'confirmada',  1200.00),
(7, 8, 4, '2026-10-05', '2026-10-08', 'confirmada',  1640.00),
(8,10, 1, '2026-10-10', '2026-10-12', 'pendente',     700.00);

-- SERVIÇOS
INSERT INTO servico (nome, descricao, preco) VALUES
('Cafe da Manha Buffet',  'Cafe da manha completo com buffet variado.',        35.00),
('Almoco no Restaurante', 'Almoco a la carte no restaurante interno.',         65.00),
('Jantar Romantico',      'Jantar especial para dois com vinho incluso.',     180.00),
('Spa e Massagem',        'Sessao de 60 minutos no spa do hotel.',            120.00),
('Lavanderia Express',    'Lavagem e entrega em 4 horas.',                     45.00),
('Transfer Aeroporto',    'Translado hotel-aeroporto.',                        80.00),
('Aluguel de Bicicleta',  'Bicicleta disponivel por 1 dia.',                  30.00),
('Baby Sitter',           'Servico de baba credenciada por periodo de 3h.',   90.00),
('Minibar Premium',       'Reposicao completa do minibar com opcoes premium.', 55.00),
('Internet Fibra Otica',  'Upgrade de internet ultra-rapida no quarto.',       20.00);

-- RESERVA_SERVICO
INSERT INTO reserva_servico (id_reserva, id_servico, quantidade, valor_unitario) VALUES
(1, 1, 3,  35.00),   -- Reserva 1: cafe 3x
(2, 1, 3,  35.00),   -- Reserva 2: cafe 3x
(2, 4, 1, 120.00),   -- Reserva 2: spa 1x
(2, 6, 1,  80.00),   -- Reserva 2: transfer 1x
(3, 1, 3,  35.00),   -- Reserva 3: cafe 3x
(3, 3, 2, 180.00),   -- Reserva 3: jantar romantico 2x
(3, 4, 1, 120.00),   -- Reserva 3: spa 1x
(4, 1, 2,  35.00),   -- Reserva 4: cafe 2x
(4, 5, 1,  45.00),   -- Reserva 4: lavanderia 1x
(5, 1, 4,  35.00),   -- Reserva 5: cafe 4x
(6, 1, 4,  35.00),   -- Reserva 6: cafe 4x
(6, 8, 2,  90.00),   -- Reserva 6: baby sitter 2x
(6, 7, 2,  30.00),   -- Reserva 6: bicicleta 2x
(7, 1, 3,  35.00),   -- Reserva 7: cafe 3x
(7, 3, 1, 180.00),   -- Reserva 7: jantar romantico 1x
(7, 9, 3,  55.00);   -- Reserva 7: minibar 3x

-- PAGAMENTOS
INSERT INTO pagamento (id_reserva, valor, data_pagamento, forma_pagamento, status) VALUES
(1,  590.00, '2026-09-13 12:30:00', 'pix',           'aprovado'),
(2, 1120.00, '2026-09-18 14:00:00', 'cartao_credito','aprovado'),
(3, 1640.00, '2026-09-23 11:00:00', 'cartao_credito','aprovado'),
(4,  430.00, '2026-09-24 16:45:00', 'dinheiro',      'aprovado'),
(5,  360.00, '2026-10-01 14:00:00', 'cartao_debito', 'aprovado'),
(6,  600.00, '2026-10-03 15:20:00', 'pix',           'aprovado'),
(7, 1640.00, '2026-10-05 09:00:00', 'cartao_credito','aprovado');

-- NOTAS FISCAIS
INSERT INTO nota_fiscal (id_pagamento, numero_nota, data_emissao, valor_total, descricao) VALUES
(1, 'NF-2026-0001', '2026-09-13 12:35:00',  590.00, 'Hospedagem - Carlos Eduardo Alves'),
(2, 'NF-2026-0002', '2026-09-18 14:05:00', 1120.00, 'Hospedagem - Mariana Oliveira'),
(3, 'NF-2026-0003', '2026-09-23 11:05:00', 1640.00, 'Hospedagem - Joao Pedro Santos'),
(4, 'NF-2026-0004', '2026-09-24 16:50:00',  430.00, 'Hospedagem - Fernanda Lima'),
(5, 'NF-2026-0005', '2026-10-01 14:05:00',  360.00, 'Pagamento parcial - Roberto Carvalho'),
(6, 'NF-2026-0006', '2026-10-03 15:25:00',  600.00, 'Pagamento parcial - Luciana Teixeira'),
(7, 'NF-2026-0007', '2026-10-05 09:05:00', 1640.00, 'Hospedagem - Andre Moura');

-- ============================================================
-- UPDATE - Atualizações de dados
-- ============================================================

-- Quarto 104 disponível após checkout
UPDATE quarto SET status = 'disponivel' WHERE numero = '104';

-- Quarto 202 disponível após manutenção concluída
UPDATE quarto SET status = 'disponivel' WHERE numero = '202';

-- Funcionária promovida
UPDATE funcionario
   SET cargo = 'Supervisora de Limpeza', salario = 2400.00
 WHERE cpf = '33344455522';

-- Reserva 5 valor atualizado após serviços adicionais
UPDATE reserva SET valor_total = 860.00 WHERE id_reserva = 5;

-- ============================================================
-- DELETE - Remoção de dados (exemplo)
-- ============================================================

-- Inativar serviço descontinuado (soft delete)
UPDATE servico SET ativo = FALSE WHERE nome = 'Internet Fibra Otica';

-- ============================================================
-- DQL - DATA QUERY LANGUAGE (SELECTs com JOIN)
-- ============================================================

-- CONSULTA 1: Reservas do último mês com dados completos
SELECT
    r.id_reserva,
    h.nome                                    AS hospede,
    h.email,
    q.numero                                  AS quarto,
    tq.nome                                   AS tipo_quarto,
    r.data_checkin,
    r.data_checkout,
    (r.data_checkout - r.data_checkin)        AS diarias,
    tq.preco_diaria,
    r.status,
    r.valor_total
FROM reserva r
JOIN hospede    h  ON r.id_hospede = h.id_hospede
JOIN quarto     q  ON r.id_quarto  = q.id_quarto
JOIN tipo_quarto tq ON q.id_tipo   = tq.id_tipo
WHERE r.data_reserva >= NOW() - INTERVAL '30 days'
ORDER BY r.data_reserva DESC;


-- CONSULTA 2: Notas fiscais emitidas no último mês
SELECT
    nf.numero_nota,
    nf.data_emissao,
    h.nome                  AS hospede,
    h.cpf,
    q.numero                AS quarto,
    tq.nome                 AS tipo_quarto,
    r.data_checkin,
    r.data_checkout,
    p.forma_pagamento,
    p.valor                 AS valor_pago,
    nf.valor_total
FROM nota_fiscal nf
JOIN pagamento   p  ON nf.id_pagamento = p.id_pagamento
JOIN reserva     r  ON p.id_reserva    = r.id_reserva
JOIN hospede     h  ON r.id_hospede    = h.id_hospede
JOIN quarto      q  ON r.id_quarto     = q.id_quarto
JOIN tipo_quarto tq ON q.id_tipo       = tq.id_tipo
WHERE nf.data_emissao >= NOW() - INTERVAL '30 days'
ORDER BY nf.data_emissao DESC;


-- CONSULTA 3: Serviços consumidos por reserva
SELECT
    r.id_reserva,
    h.nome               AS hospede,
    q.numero             AS quarto,
    s.nome               AS servico,
    rs.quantidade,
    rs.valor_unitario,
    (rs.quantidade * rs.valor_unitario) AS subtotal,
    rs.data_solicitacao
FROM reserva_servico rs
JOIN reserva  r ON rs.id_reserva = r.id_reserva
JOIN hospede  h ON r.id_hospede  = h.id_hospede
JOIN quarto   q ON r.id_quarto   = q.id_quarto
JOIN servico  s ON rs.id_servico = s.id_servico
ORDER BY r.id_reserva, rs.data_solicitacao;


-- CONSULTA 4: Ocupação por tipo de quarto
SELECT
    tq.nome                AS tipo_quarto,
    tq.preco_diaria,
    COUNT(q.id_quarto)     AS total_quartos,
    SUM(CASE WHEN q.status = 'disponivel'  THEN 1 ELSE 0 END) AS disponiveis,
    SUM(CASE WHEN q.status = 'ocupado'     THEN 1 ELSE 0 END) AS ocupados,
    SUM(CASE WHEN q.status = 'reservado'   THEN 1 ELSE 0 END) AS reservados,
    SUM(CASE WHEN q.status = 'manutencao'  THEN 1 ELSE 0 END) AS em_manutencao
FROM tipo_quarto tq
LEFT JOIN quarto q ON tq.id_tipo = q.id_tipo
GROUP BY tq.id_tipo, tq.nome, tq.preco_diaria
ORDER BY tq.preco_diaria;


-- CONSULTA 5: Ranking dos serviços mais consumidos
SELECT
    s.nome                                       AS servico,
    s.preco                                      AS preco_unitario,
    SUM(rs.quantidade)                           AS qtd_total,
    SUM(rs.quantidade * rs.valor_unitario)       AS receita_total
FROM reserva_servico rs
JOIN servico s ON rs.id_servico = s.id_servico
GROUP BY s.id_servico, s.nome, s.preco
ORDER BY qtd_total DESC;


-- CONSULTA 6: Clientes frequentes (programa de fidelidade)
SELECT
    h.id_hospede,
    h.nome               AS hospede,
    h.email,
    h.telefone,
    COUNT(r.id_reserva)  AS total_reservas,
    SUM(r.valor_total)   AS total_gasto,
    MAX(r.data_checkin)  AS ultima_estadia
FROM hospede h
JOIN reserva r ON h.id_hospede = r.id_hospede
WHERE r.status <> 'cancelada'
GROUP BY h.id_hospede, h.nome, h.email, h.telefone
ORDER BY total_reservas DESC, total_gasto DESC;


-- CONSULTA 7: Faturamento mensal por forma de pagamento
SELECT
    TO_CHAR(p.data_pagamento, 'YYYY-MM') AS mes,
    p.forma_pagamento,
    COUNT(p.id_pagamento)                AS total_transacoes,
    SUM(p.valor)                         AS faturamento
FROM pagamento p
WHERE p.status = 'aprovado'
GROUP BY TO_CHAR(p.data_pagamento, 'YYYY-MM'), p.forma_pagamento
ORDER BY mes DESC, faturamento DESC;


-- CONSULTA 8: Quartos disponíveis para período específico
SELECT
    q.numero,
    tq.nome              AS tipo_quarto,
    q.andar,
    tq.capacidade,
    tq.preco_diaria,
    q.status
FROM quarto q
JOIN tipo_quarto tq ON q.id_tipo = tq.id_tipo
WHERE q.status = 'disponivel'
  AND q.id_quarto NOT IN (
      SELECT r.id_quarto
      FROM reserva r
      WHERE r.status NOT IN ('cancelada','concluida')
        AND r.data_checkin  < '2026-10-15'
        AND r.data_checkout > '2026-10-10'
  )
ORDER BY tq.preco_diaria, q.numero;


-- CONSULTA 9: Desempenho dos funcionários por check-ins
SELECT
    f.nome                    AS funcionario,
    f.cargo,
    COUNT(r.id_reserva)       AS checkins_realizados,
    SUM(r.valor_total)        AS valor_gerenciado
FROM funcionario f
LEFT JOIN reserva r ON f.id_funcionario = r.id_funcionario
WHERE f.ativo = TRUE
GROUP BY f.id_funcionario, f.nome, f.cargo
ORDER BY checkins_realizados DESC;


-- CONSULTA 10: Check-outs pendentes com saldo a pagar
SELECT
    r.id_reserva,
    h.nome                           AS hospede,
    h.telefone,
    q.numero                         AS quarto,
    tq.nome                          AS tipo_quarto,
    r.data_checkin,
    r.data_checkout,
    r.valor_total,
    COALESCE(SUM(p.valor), 0)        AS valor_pago,
    (r.valor_total - COALESCE(SUM(p.valor), 0)) AS saldo_pendente
FROM reserva r
JOIN hospede     h  ON r.id_hospede = h.id_hospede
JOIN quarto      q  ON r.id_quarto  = q.id_quarto
JOIN tipo_quarto tq ON q.id_tipo    = tq.id_tipo
LEFT JOIN pagamento p ON r.id_reserva = p.id_reserva
                     AND p.status = 'aprovado'
WHERE r.status = 'em_andamento'
  AND r.data_checkout <= CURRENT_DATE
GROUP BY r.id_reserva, h.nome, h.telefone, q.numero,
         tq.nome, r.data_checkin, r.data_checkout, r.valor_total
ORDER BY r.data_checkout;

-- ============================================================
-- FIM DO SCRIPT - Hotel Bela Vista
-- ============================================================
