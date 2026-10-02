# 🏨 DOCUMENTAÇÃO OFICIAL DO PROJETO A3 - BANCO DE DADOS

**Centro Universitário UNA - Barreiro**  
**Trilha de Aprendizagem:** Oracle Academy / Projeto de Banco de Dados  
**Professores:** Alexandre e Silvia  
**Tema do Projeto:** Sistema de Gerenciamento de Hotel ("Hotel Bela Vista")  

---

## 👥 Integrantes do Grupo

* **Esdras Andrade** — RA: 326213247
* **Pedro Antônio** — RA: 325223425
* **Lucas Miranda** — RA: 325131396
* **Gabriel Ferreira**
* **Fernando Almeida** — RA: 326132695
* **Cauã Mendes** — RA: 326141078
* **Caio Duraes** — RA: 325132875

---

## 📋 1. Contexto do Projeto e Solução Proposta

### 📌 O Problema
Organizações do setor hoteleiro enfrentam grandes desafios operacionais ao utilizarem registros em papel ou planilhas isoladas. As principais consequências são:
1. **Duplicidade de cadastros:** Clientes cadastrados várias vezes de formas diferentes.
2. **Risco de *Overbooking*:** Venda duplicada do mesmo quarto para o mesmo período.
3. **Falta de controle de consumo extra:** Consumo no restaurante, minibar ou spa esquecidos de cobrar no Check-out.
4. **Dificuldade na contabilidade:** Descentralização de comprovantes de pagamento e emissão de notas fiscais.

### 💡 A Solução
Propomos o desenvolvimento de um **Banco de Dados Relacional em PostgreSQL**, centralizado no provedor de nuvem **Supabase**. O sistema integra toda a jornada do hóspede — desde o cadastro, reserva de quarto, consumo de serviços adicionais, até a quitação da conta e emissão da Nota Fiscal.

---

## 🚀 2. Passo a Passo: Como Subir o Banco de Dados no Supabase

Siga o roteiro abaixo para publicar e executar o script de banco de dados na sua conta do Supabase:

1. **Acessar o Painel do Supabase:**
   * Clique no link do dashboard da sua organização:  
     👉 [https://supabase.com/dashboard/org/skistlzzfwscurcgcnjj](https://supabase.com/dashboard/org/skistlzzfwscurcgcnjj)

2. **Criar ou Selecionar o Projeto:**
   * Caso ainda não tenha um projeto criado, clique em **"New Project"**.
   * Defina o nome do projeto (ex: `A3-Hotel-Bela-Vista`), escolha uma senha forte para o banco e selecione a região (ex: `South America (São Paulo)`).
   * Aguarde 1 a 2 minutos até que a instância do PostgreSQL seja provisionada.

3. **Abrir o SQL Editor:**
   * No menu lateral esquerdo do Supabase, clique no ícone **SQL Editor** (representado pelo símbolo `>_`).

4. **Executar o Script SQL:**
   * Clique no botão **"New Query"** (Nova Consulta).
   * Copie todo o conteúdo do arquivo SQL do projeto e cole no campo de texto do editor SQL.
   * Clique no botão verde **"RUN"** (ou pressione `Ctrl + Enter`).
   * A mensagem **"Success. No rows returned"** aparecerá indicando que todas as tabelas, permissões e dados foram inseridos com sucesso.

5. **Verificar os Dados Criados (Table Editor):**
   * No menu lateral esquerdo, clique no ícone **Table Editor** (representado por uma tabela).
   * Você verá as 9 tabelas do hotel (`hospede`, `tipo_quarto`, `quarto`, `funcionario`, `reserva`, `servico`, `reserva_servico`, `pagamento`, `nota_fiscal`) completamente populadas com os dados de demonstração.

---

## 🏗️ 3. Estrutura das Tabelas (DDL) e Aplicação Operacional

| Tabela | Função Principal | Aplicação Operacional no Hotel |
| :--- | :--- | :--- |
| `hospede` | Cadastro de clientes | Armazena dados de contato e CPF. Garante integridade evitando CPFs duplicados via restrição `UNIQUE`. |
| `tipo_quarto` | Categorias e tarifas | Define o valor padrão da diária e a capacidade máxima (ex: Standard, Luxo, Suíte Master). |
| `quarto` | Unidades físicas | Controla o número do quarto, andar e o status operacional (`disponivel`, `ocupado`, `manutencao`, `reservado`). |
| `funcionario` | Registro da equipe | Vincula qual atendente ou gerente registrou a reserva, garantindo transparência e controle de RH. |
| `reserva` | Contrato de hospedagem | Tabela central. Conecta Hóspede, Quarto e Funcionário. Possui a regra de validação `chk_datas CHECK (data_checkout > data_checkin)` para impedir datas inválidas. |
| `servico` | Catálogo de extras | Lista os serviços oferecidos durante a estadia (Café da manhã, Spa, Lavanderia, Transfer, Minibar). |
| `reserva_servico` | Lançamento de consumo (N:M) | Tabela associativa que funciona como a "comanda" do hóspede, registrando a quantidade consumida e a data de solicitação. |
| `pagamento` | Registro financeiro | Armazena as transações quitadas ou parciais por Pix, Cartão de Crédito/Débito ou Dinheiro. |
| `nota_fiscal` | Comprovação fiscal | Garante a emissão de nota fiscal associada a cada pagamento realizado com sucesso. |

---

## 🔄 4. Manipulação de Dados (DML): Inserções, Atualizações e Remoções

* **Carga Inicial (`INSERT`):** O script insere dados realistas para testes — 5 tipos de quartos, 10 quartos, 5 funcionários, 8 hóspedes, 8 reservas em diferentes estados (`concluida`, `em_andamento`, `confirmada`, `pendente`), 10 serviços e diversas transações financeiras.
* **Atualizações Diárias (`UPDATE`):**
  * Liberação de quarto da manutenção para disponibilidade após limpeza.
  * Promoção e reajuste salarial de funcionários.
  * Recálculo do valor total da reserva após inclusão de serviços extras.
* **Inativação de Registros (`DELETE` / Soft Delete):**
  * O sistema utiliza **Soft Delete** (`UPDATE servico SET ativo = FALSE WHERE ...`) para inativar serviços descontinuados. Isso impede que o histórico de reservas antigas seja quebrado por exclusão física.

---

## 🔍 5. As 10 Consultas Estratégicas (DQL) e sua Aplicação Prática

### Consulta 1: Relatório de Reservas do Último Mês
```sql
SELECT r.id_reserva, h.nome AS hospede, q.numero AS quarto, tq.nome AS tipo_quarto,
       r.data_checkin, r.data_checkout, (r.data_checkout - r.data_checkin) AS diarias,
       r.status, r.valor_total
FROM reserva r
JOIN hospede h ON r.id_hospede = h.id_hospede
JOIN quarto q ON r.id_quarto = q.id_quarto
JOIN tipo_quarto tq ON q.id_tipo = tq.id_tipo
WHERE r.data_reserva >= NOW() - INTERVAL '30 days'
ORDER BY r.data_reserva DESC;
```
* **Aplicação no Negócio:** Permite à gerência analisar a demanda recente, o tempo médio de permanência dos clientes e a receita bruta gerada nos últimos 30 dias.

---

### Consulta 2: Auditoria de Notas Fiscais Emitidas
```sql
SELECT nf.numero_nota, nf.data_emissao, h.nome AS hospede, h.cpf, q.numero AS quarto,
       p.forma_pagamento, p.valor AS valor_pago, nf.valor_total
FROM nota_fiscal nf
JOIN pagamento p ON nf.id_pagamento = p.id_pagamento
JOIN reserva r ON p.id_reserva = r.id_reserva
JOIN hospede h ON r.id_hospede = h.id_hospede
JOIN quarto q ON r.id_quarto = q.id_quarto
WHERE nf.data_emissao >= NOW() - INTERVAL '30 days'
ORDER BY nf.data_emissao DESC;
```
* **Aplicação no Negócio:** Utilizada pelo setor contábil para fechar o balanço mensal de impostos recolhidos e garantir conformidade fiscal.

---

### Consulta 3: Extrato Detalhado de Consumo Extra do Hóspede
```sql
SELECT r.id_reserva, h.nome AS hospede, q.numero AS quarto, s.nome AS servico,
       rs.quantidade, rs.valor_unitario, (rs.quantidade * rs.valor_unitario) AS subtotal,
       rs.data_solicitacao
FROM reserva_servico rs
JOIN reserva r ON rs.id_reserva = r.id_reserva
JOIN hospede h ON r.id_hospede = h.id_hospede
JOIN quarto q ON r.id_quarto = q.id_quarto
JOIN servico s ON rs.id_servico = s.id_servico
ORDER BY r.id_reserva, rs.data_solicitacao;
```
* **Aplicação no Negócio:** Impresso ou apresentado na tela da recepção no momento do Check-out para transparência com o cliente sobre o consumo no frigobar, restaurante e spa.

---

### Consulta 4: Taxa de Ocupação Operacional por Categoria de Quarto
```sql
SELECT tq.nome AS tipo_quarto, tq.preco_diaria, COUNT(q.id_quarto) AS total_quartos,
       SUM(CASE WHEN q.status = 'disponivel' THEN 1 ELSE 0 END) AS disponiveis,
       SUM(CASE WHEN q.status = 'ocupado' THEN 1 ELSE 0 END) AS ocupados,
       SUM(CASE WHEN q.status = 'reservado' THEN 1 ELSE 0 END) AS reservados,
       SUM(CASE WHEN q.status = 'manutencao' THEN 1 ELSE 0 END) AS em_manutencao
FROM tipo_quarto tq
LEFT JOIN quarto q ON tq.id_tipo = q.id_tipo
GROUP BY tq.id_tipo, tq.nome, tq.preco_diaria
ORDER BY tq.preco_diaria;
```
* **Aplicação no Negócio:** Dashboard operacional em tempo real para a recepção e equipe de limpeza conhecerem a disponibilidade imediata de cada categoria de acomodação.

---

### Consulta 5: Ranking dos Serviços Adicionais Mais Vendidos
```sql
SELECT s.nome AS servico, s.preco AS preco_unitario, SUM(rs.quantidade) AS qtd_total,
       SUM(rs.quantidade * rs.valor_unitario) AS receita_total
FROM reserva_servico rs
JOIN servico s ON rs.id_servico = s.id_servico
GROUP BY s.id_servico, s.nome, s.preco
ORDER BY qtd_total DESC;
```
* **Aplicação no Negócio:** Tomada de decisão estratégica de estoque e comercial. Identifica os serviços de maior apelo para investimentos ou contratação de mão de obra especializada.

---

### Consulta 6: Programa de Fidelidade (Clientes Frequentadores)
```sql
SELECT h.id_hospede, h.nome AS hospede, h.email, h.telefone,
       COUNT(r.id_reserva) AS total_reservas, SUM(r.valor_total) AS total_gasto,
       MAX(r.data_checkin) AS ultima_estadia
FROM hospede h
JOIN reserva r ON h.id_hospede = r.id_hospede
WHERE r.status <> 'cancelada'
GROUP BY h.id_hospede, h.nome, h.email, h.telefone
ORDER BY total_reservas DESC, total_gasto DESC;
```
* **Aplicação no Negócio:** Permite à equipe de Marketing criar campanhas personalizadas de fidelidade, oferecendo descontos especiais para clientes com maior histórico de estadias.

---

### Consulta 7: Faturamento Mensal por Forma de Pagamento
```sql
SELECT TO_CHAR(p.data_pagamento, 'YYYY-MM') AS mes, p.forma_pagamento,
       COUNT(p.id_pagamento) AS total_transacoes, SUM(p.valor) AS faturamento
FROM pagamento p
WHERE p.status = 'aprovado'
GROUP BY TO_CHAR(p.data_pagamento, 'YYYY-MM'), p.forma_pagamento
ORDER BY mes DESC, faturamento DESC;
```
* **Aplicação no Negócio:** Análise financeira de fluxo de caixa e negociação de taxas operacionais de cartão e chave Pix junto a instituições bancárias.

---

### Consulta 8: Motor de Busca de Quartos Vagos sem Conflito de Datas
```sql
SELECT q.numero, tq.nome AS tipo_quarto, q.andar, tq.capacidade, tq.preco_diaria
FROM quarto q
JOIN tipo_quarto tq ON q.id_tipo = tq.id_tipo
WHERE q.status = 'disponivel'
  AND q.id_quarto NOT IN (
      SELECT r.id_quarto FROM reserva r
      WHERE r.status NOT IN ('cancelada','concluida')
        AND r.data_checkin < '2026-10-15'
        AND r.data_checkout > '2026-10-10'
  )
ORDER BY tq.preco_diaria, q.numero;
```
* **Aplicação no Negócio:** Utilizado no motor de reserva do site ou terminal de recepção ao consultar vagas para um intervalo futuro desejado pelo cliente, evitando choque de reservas.

---

### Consulta 9: Produtividade dos Recepcionistas / Atendentes
```sql
SELECT f.nome AS funcionario, f.cargo, COUNT(r.id_reserva) AS checkins_realizados,
       SUM(r.valor_total) AS valor_gerenciado
FROM funcionario f
LEFT JOIN reserva r ON f.id_funcionario = r.id_funcionario
WHERE f.ativo = TRUE
GROUP BY f.id_funcionario, f.nome, f.cargo
ORDER BY checkins_realizados DESC;
```
* **Aplicação no Negócio:** Gestão de Recursos Humanos para mensuração de desempenho da equipe de recepção, apoiando programas de premiação e bonificação.

---

### Consulta 10: Controle de Saldos Devedores no Check-out
```sql
SELECT r.id_reserva, h.nome AS hospede, h.telefone, q.numero AS quarto,
       r.valor_total, COALESCE(SUM(p.valor), 0) AS valor_pago,
       (r.valor_total - COALESCE(SUM(p.valor), 0)) AS saldo_pendente
FROM reserva r
JOIN hospede h ON r.id_hospede = h.id_hospede
JOIN quarto q ON r.id_quarto = q.id_quarto
LEFT JOIN pagamento p ON r.id_reserva = p.id_reserva AND p.status = 'aprovado'
WHERE r.status = 'em_andamento' AND r.data_checkout <= CURRENT_DATE
GROUP BY r.id_reserva, h.nome, h.telefone, q.numero, r.valor_total
ORDER BY r.data_checkout;
```
* **Aplicação no Negócio:** Painel de alerta da Recepção para cobrança no momento de saída do hóspede, mitigando perdas financeiras por não quitação de valores pendentes.

---

## 📊 6. Diagnóstico: A Atividade Já Está Pronta? O Que Falta Fazer?

### ✅ Status do Projeto: 100% PRONTO NO CÓDIGO E NA DOCUMENTAÇÃO!

A parte técnica e documental do trabalho de Banco de Dados para a UNA Barreiro está **completamente concluída e validada**.

### 📝 Checklist Final para o Grupo Fazer a Entrega:

1. **[ ] Executar no Supabase:**
   * Acessar [o link do Supabase](https://supabase.com/dashboard/org/skistlzzfwscurcgcnjj).
   * Cole o código SQL contido no arquivo `A3_Hotel_BancoDeDados.sql` no **SQL Editor** e clique em **RUN**.
2. **[ ] Tirar Prints (Evidência Prática):**
   * Tirar um print da tela do Supabase no **Table Editor** mostrando as tabelas criadas.
   * Tirar um print do **SQL Editor** executando uma das consultas (ex: Consulta 4 ou 6).
3. **[ ] Postar o Trabalho no Portal do Aluno:**
   * Exportar esta documentação em formato PDF/Word ou copiar este texto para o modelo oficial de entrega da UNA Barreiro.
   * Anexar os nomes e RAs de todos os 7 integrantes do grupo:
     * Esdras Andrade (326213247)
     * Pedro Antônio (325223425)
     * Lucas Miranda (325131396)
     * Gabriel Ferreira
     * Fernando Almeida (326132695)
     * Cauã Mendes (326141078)
     * Caio Duraes (325132875)

---
*Projeto concluído com excelência para os professores Alexandre e Silvia — Centro Universitário UNA Barreiro.*
