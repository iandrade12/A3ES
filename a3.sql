-- Tabela Fornecedores
CREATE TABLE Fornecedores (
    id_fornecedor INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL,
    contato VARCHAR(255),
    endereco VARCHAR(255)
);

-- Tabela Produtos
CREATE TABLE Produtos (
    id_produto INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL,
    marca VARCHAR(255),
    modelo VARCHAR(255),
    cor VARCHAR(50),
    tamanho INT,
    preco_compra DECIMAL(10, 2),
    preco_venda DECIMAL(10, 2),
    id_fornecedor INT,
    quantidade_estoque INT,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(id_fornecedor)
);

-- Tabela Clientes
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL,
    telefone VARCHAR(50),
    email VARCHAR(100),
    endereco VARCHAR(255)
);

-- Tabela MetodosPagamento
CREATE TABLE MetodosPagamento (
    id_metodo INT PRIMARY KEY IDENTITY(1,1),
    metodo VARCHAR(50) NOT NULL
);

-- Tabela Vendas
CREATE TABLE Vendas (
    id_venda INT PRIMARY KEY IDENTITY(1,1),
    data DATE NOT NULL,
    valor_total DECIMAL(10, 2),
    id_cliente INT,
    id_metodo INT,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_metodo) REFERENCES MetodosPagamento(id_metodo)
);

-- Tabela ItensVenda
CREATE TABLE ItensVenda (
    id_item INT PRIMARY KEY IDENTITY(1,1),
    id_venda INT,
    id_produto INT,
    quantidade INT,
    preco_unitario DECIMAL(10, 2),
    subtotal DECIMAL(10, 2),
    FOREIGN KEY (id_venda) REFERENCES Vendas(id_venda),
    FOREIGN KEY (id_produto) REFERENCES Produtos(id_produto)
);

-- Tabela Compras
CREATE TABLE Compras (
    id_compra INT PRIMARY KEY IDENTITY(1,1),
    data DATE NOT NULL,
    valor_total DECIMAL(10, 2),
    id_fornecedor INT,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(id_fornecedor)
);

-- Tabela ItensCompra
CREATE TABLE ItensCompra (
    id_item INT PRIMARY KEY IDENTITY(1,1),
    id_compra INT,
    id_produto INT,
    quantidade INT,
    preco_unitario DECIMAL(10, 2),
    subtotal DECIMAL(10, 2),
    FOREIGN KEY (id_compra) REFERENCES Compras(id_compra),
    FOREIGN KEY (id_produto) REFERENCES Produtos(id_produto)
);

-- Tabela Categorias
CREATE TABLE Categorias (
    id_categoria INT PRIMARY KEY IDENTITY(1,1),
    nome_categoria VARCHAR(50) NOT NULL
);

-- Tabela Transacoes
CREATE TABLE Transacoes (
    id_transacao INT PRIMARY KEY IDENTITY(1,1),
    id_categoria INT,
    tipo VARCHAR(20), -- Pode ser 'Receita' ou 'Despesa'
    valor DECIMAL(10, 2),
    data DATE NOT NULL,
    descricao VARCHAR(255),
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

CREATE PROCEDURE CalcularSaldoFluxoCaixa
AS
BEGIN
    -- Declarar as variáveis para melhor controle de erros e flexibilidade
    BEGIN TRY
        SELECT 
            SUM(CASE WHEN t.tipo = 'Receita' THEN t.valor ELSE 0 END) AS TotalReceitas,
            SUM(CASE WHEN t.tipo = 'Despesa' THEN t.valor ELSE 0 END) AS TotalDespesas,
            SUM(CASE WHEN t.tipo = 'Receita' THEN t.valor ELSE -t.valor END) AS Saldo
        FROM Transacoes t
        LEFT JOIN Categorias c ON t.id_categoria = c.id_categoria;
    END TRY
    BEGIN CATCH
        -- Em caso de erro, exibe mensagem
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END;

CREATE PROCEDURE GerarRelatorioReceitasDespesas
AS
BEGIN
    BEGIN TRY
        -- Seleção dos dados agrupados por Categoria e Tipo
        SELECT 
            c.nome_categoria AS Categoria, -- Nome ajustado para o nome correto do atributo
            t.tipo AS Tipo,               -- Garantido que o tipo está sendo referenciado corretamente
            SUM(t.valor) AS Total
        FROM Transacoes t
        LEFT JOIN Categorias c 
            ON t.id_categoria = c.id_categoria
        GROUP BY c.nome_categoria, t.tipo; -- Correção na referência dos campos no GROUP BY
    END TRY
    BEGIN CATCH
        -- Tratamento de erros
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END;

CREATE PROCEDURE GerarRelatorioReceitasDespesas
AS
BEGIN
    BEGIN TRY
        -- Seleção dos dados agrupados por Categoria e Tipo
        SELECT 
            c.nome_categoria AS Categoria, -- Nome ajustado para o nome correto do atributo
            t.tipo AS Tipo,               -- Garantido que o tipo está sendo referenciado corretamente
            SUM(t.valor) AS Total
        FROM Transacoes t
        LEFT JOIN Categorias c 
            ON t.id_categoria = c.id_categoria
        GROUP BY c.nome_categoria, t.tipo; -- Correção na referência dos campos no GROUP BY
    END TRY
    BEGIN CATCH
        -- Tratamento de erros
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END;

CREATE PROCEDURE ProjetarFluxoCaixaFuturo
    @Meses INT
AS
BEGIN
    -- Declarar variáveis para cálculos
    DECLARE @ReceitaMensal DECIMAL(10, 2) = 0;
    DECLARE @DespesaMensal DECIMAL(10, 2) = 0;
    DECLARE @SaldoProjecao DECIMAL(10, 2) = 0;

    BEGIN TRY
        -- Calcular média mensal de receitas
        SELECT 
            @ReceitaMensal = ISNULL(SUM(valor) / NULLIF(COUNT(DISTINCT DATEPART(MONTH, data)), 0), 0)
        FROM Transacoes t
        INNER JOIN Categorias c ON t.id_categoria = c.id_categoria
        WHERE c.tipo = 'Receita';

        -- Calcular média mensal de despesas
        SELECT 
            @DespesaMensal = ISNULL(SUM(valor) / NULLIF(COUNT(DISTINCT DATEPART(MONTH, data)), 0), 0)
        FROM Transacoes t
        INNER JOIN Categorias c ON t.id_categoria = c.id_categoria
        WHERE c.tipo = 'Despesa';

        -- Calcular projeção de saldo futuro
        SET @SaldoProjecao = (@ReceitaMensal - @DespesaMensal) * @Meses;

        -- Exibir projeção
        SELECT 
            @ReceitaMensal AS Receita_Media_Mensal,
            @DespesaMensal AS Despesa_Media_Mensal,
            @SaldoProjecao AS Projecao_Fluxo_Caixa;

    END TRY
    BEGIN CATCH
        -- Tratamento de erros
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END;

CREATE PROCEDURE ValidarInsercaoTransacao
    @Data DATETIME,
    @Valor DECIMAL(10, 2),
    @IdCategoria INT,
    @IdMetodo INT,
    @Descricao NVARCHAR(200)
AS
BEGIN
    BEGIN TRY
        -- Verificar se o valor é maior que zero
        IF @Valor <= 0
        BEGIN
            THROW 50001, 'O valor da transação deve ser maior que zero.', 1;
        END;

        -- Verificar se a categoria existe
        IF NOT EXISTS (SELECT 1 FROM Categorias WHERE id_categoria = @IdCategoria)
        BEGIN
            THROW 50002, 'Categoria inválida. Verifique o ID da categoria.', 1;
        END;

        -- Inserir a transação se todos os dados forem válidos
        INSERT INTO Transacoes (data, valor, id_categoria, id_metodo, descricao)
        VALUES (@Data, @Valor, @IdCategoria, @IdMetodo, @Descricao);

        PRINT 'Transação inserida com sucesso.';
    END TRY
    BEGIN CATCH
        -- Capturar erros e retornar mensagem personalizada
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

CREATE FUNCTION CalcularVPL (
    @InvestimentoInicial DECIMAL(10, 2),
    @TaxaDesconto DECIMAL(10, 4)
)
RETURNS @Resultado TABLE (
    VPL DECIMAL(18, 2)
)
AS
BEGIN
    DECLARE @VPL DECIMAL(18, 2) = 0
   
    DECLARE @FluxosCaixa TABLE 
   END  
CREATE PROCEDURE CalcularTIR
    @InvestimentoInicial DECIMAL(18, 2),
    @FluxosCaixa TABLE (Periodo INT, Valor DECIMAL(18, 2)),
    @IteracoesMaximas INT = 1000,
    @Precisao DECIMAL(10, 6) = 0.000001,
    @TIR DECIMAL(10, 6) OUTPUT
AS
BEGIN
    DECLARE @Taxa DECIMAL(10, 6) = 0.10; -- Chute inicial (10%)
    DECLARE @VPL DECIMAL(18, 2);
    DECLARE @Delta DECIMAL(10, 6);
    DECLARE @Iteracao INT = 0;
    WHILE @Iteracao < @IteracoesMaximas
    BEGIN
        -- Calcular o VPL atual
        SET @VPL = 0;
        SELECT @VPL = @VPL + (Valor / POWER(1 + @Taxa, Periodo))
        FROM @FluxosCaixa;
        SET @VPL = @VPL - @InvestimentoInicial;

        -- Calcular derivada aproximada (f'(r)) usando perturbação
        DECLARE @VPLDerivada DECIMAL(18, 2) = 0;
        SELECT @VPLDerivada = @VPLDerivada + (-Periodo * Valor / POWER(1 + @Taxa, Periodo + 1))
        FROM @FluxosCaixa;
        -- Ajustar delta com base na derivada
        IF ABS(@VPLDerivada) < @Precisao BREAK; -- Evitar divisão por zero
        SET @Delta = @VPL / @VPLDerivada;
        -- Verificar a precisão
        IF ABS(@Delta) < @Precisao
            BREAK;
        -- Atualizar a taxa
        SET @Taxa = @Taxa - @Delta;
        SET @Iteracao = @Iteracao + 1;
    END;
    -- Retornar a TIR calculada
    SET @TIR = @Taxa;
END;
GO


