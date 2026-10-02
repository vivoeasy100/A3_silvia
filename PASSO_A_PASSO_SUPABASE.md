# 🚀 GUIA PASSO A PASSO: IMPLANTAÇÃO DO BANCO DE DADOS NO SUPABASE

**Projeto:** Sistema de Gerenciamento do Hotel Bela Vista (A3 - UNA Barreiro)  
**Banco de Dados:** PostgreSQL (versão Supabase Cloud)  
**URL do Projeto:** [https://epoqmxqetzmscctlqfeo.supabase.co](https://epoqmxqetzmscctlqfeo.supabase.co)  
**Link Direto do SQL Editor:** [https://supabase.com/dashboard/project/epoqmxqetzmscctlqfeo/sql/new](https://supabase.com/dashboard/project/epoqmxqetzmscctlqfeo/sql/new)

---

## 📌 Requisitos Prévios
* Ter o arquivo [`A3_Hotel_BancoDeDados.sql`](file:///c:/Users/ferna/Documents/Projetos/A3_Silvia/A3_Hotel_BancoDeDados.sql) aberto no VS Code ou Bloco de Notas.
* Estar logado na sua conta do Supabase.

---

## 💻 Etapa 1: Abrir o SQL Editor do seu Projeto no Supabase

1. Clique no link direto para abrir uma nova consulta no seu projeto:  
   👉 **[Abrir SQL Editor no Supabase](https://supabase.com/dashboard/project/epoqmxqetzmscctlqfeo/sql/new)**

2. Caso prefira ir manualmente: acesse o seu projeto e no menu lateral esquerdo clique no ícone **SQL Editor** (`>_`) -> clique no botão **"+ New Query"**.

---

## 📝 Etapa 2: Executar o Script SQL no Supabase

1. Abra o arquivo [`A3_Hotel_BancoDeDados.sql`](file:///c:/Users/ferna/Documents/Projetos/A3_Silvia/A3_Hotel_BancoDeDados.sql) no seu computador.
2. Selecione todo o texto (`Ctrl + A`) e copie (`Ctrl + C`).
3. Cole o código no campo de texto do **SQL Editor** no Supabase (`Ctrl + V`).
4. Clique no botão verde **"RUN"** no canto inferior direito (ou pressione `Ctrl + Enter`).
5. **Resultado Esperado:** Mensagem verde `Success. No rows returned`.

---

## 🔍 Etapa 3: Confirmar a Criação das Tabelas e Registros

1. Clique no link direto para o editor de tabelas:  
   👉 **[Table Editor do Projeto](https://supabase.com/dashboard/project/epoqmxqetzmscctlqfeo/editor)**

2. Verifique se todas as 9 tabelas (`hospede`, `tipo_quarto`, `quarto`, `funcionario`, `reserva`, `servico`, `reserva_servico`, `pagamento`, `nota_fiscal`) estão listadas e populadas com os dados.

---

## ⚡ Etapa 4: Testar uma Consulta de Demonstração

1. Volte ao **SQL Editor** (`>_`).
2. Abra uma nova aba clicando em **"+ New Query"**.
3. Digite ou cole a seguinte consulta para ver o estado dos quartos do hotel:

```sql
SELECT 
    tq.nome AS tipo_quarto,
    q.numero AS quarto,
    q.status,
    tq.preco_diaria
FROM quarto q
JOIN tipo_quarto tq ON q.id_tipo = tq.id_tipo
ORDER BY q.numero;
```

4. Clique em **RUN** e observe os resultados em formato de tabela.

---

## 📸 Etapa 5: Evidências para a Entrega da A3

Para comprovar a implantação na entrega da faculdade:

1. **Print 1 (Tabelas Criadas):** Tire uma foto/print da tela do **Table Editor** listando as tabelas e dados.
2. **Print 2 (Execução SQL):** Tire uma foto/print da tela do **SQL Editor** mostrando o comando de execução e a mensagem `Success`.

---

## 🛠️ Solução de Problemas Comuns (Troubleshooting)

* **Erro de chave estrangeira (FK Violation):** Se for rodar o script uma segunda vez no mesmo projeto, execute primeiro `DROP SCHEMA public CASCADE; CREATE SCHEMA public;` para limpar o banco zerado antes de colar o script novamente.
* **Timeout na criação:** Se a tela de criação do projeto demorar mais de 5 minutos, atualize a página (`F5`).

---
*Guia de implantação finalizado — Projeto A3 Banco de Dados UNA Barreiro.*
