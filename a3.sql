-- Tabela Fornecedores
CREATE TABLE Fornecedores (
    id_fornecedor INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL,
    contato VARCHAR(255),
    endereco VARCHAR(255)
);
GO

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
GO

-- Tabela Clientes
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL,
    telefone VARCHAR(50),
    email VARCHAR(100),
    endereco VARCHAR(255)
);
GO

-- Tabela Métodos de Pagamento
CREATE TABLE MetodosPagamento (
    id_metodo INT PRIMARY KEY IDENTITY(1,1),
    metodo VARCHAR(50) NOT NULL
);
GO

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
GO

-- Tabela Itens de Venda
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
GO

-- Tabela Compras
CREATE TABLE Compras (
    id_compra INT PRIMARY KEY IDENTITY(1,1),
    data DATE NOT NULL,
    valor_total DECIMAL(10, 2),
    id_fornecedor INT,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(id_fornecedor)
);
GO

-- Tabela Itens de Compra
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
GO

-- Tabela Categorias
CREATE TABLE Categorias (
    id_categoria INT PRIMARY KEY IDENTITY(1,1),
    nome_categoria VARCHAR(50) NOT NULL
);
GO

-- Tabela Transações
CREATE TABLE Transacoes (
    id_transacao INT PRIMARY KEY IDENTITY(1,1),
    id_categoria INT,
    tipo VARCHAR(20),
    valor DECIMAL(10, 2),
    data DATE NOT NULL,
    descricao VARCHAR(255),
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);
GO

-- Procedure: CalcularSaldoFluxoCaixa
CREATE PROCEDURE CalcularSaldoFluxoCaixa
AS
BEGIN
    BEGIN TRY
        SELECT 
            SUM(CASE WHEN t.tipo = 'Receita' THEN t.valor ELSE 0 END) AS TotalReceitas,
            SUM(CASE WHEN t.tipo = 'Despesa' THEN t.valor ELSE 0 END) AS TotalDespesas,
            SUM(CASE WHEN t.tipo = 'Receita' THEN t.valor ELSE -t.valor END) AS Saldo
        FROM Transacoes t;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- Function: CalcularVPL
CREATE FUNCTION CalcularVPL (
    @InvestimentoInicial DECIMAL(18, 2),
    @TaxaDesconto DECIMAL(10, 4)
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @VPL DECIMAL(18, 2) = 0;

   
    SELECT @VPL = SUM(Valor / POWER(1 + @TaxaDesconto, Periodo))
    FROM (
        SELECT 1 AS Periodo, 1000.00 AS Valor UNION ALL
        SELECT 2, 1200.00 UNION ALL
        SELECT 3, 1400.00
    ) Fluxos;

    RETURN @VPL - @InvestimentoInicial;
END;
GO

-- Procedure: CalcularTIR
CREATE PROCEDURE CalcularTIR
    @InvestimentoInicial DECIMAL(18, 2),
    @FluxosCaixa TABLE (Periodo INT, Valor DECIMAL(18, 2)),
    @IteracoesMaximas INT = 1000,
    @Precisao DECIMAL(10, 6) = 0.000001,
    @TIR DECIMAL(10, 6) OUTPUT
AS
BEGIN
    DECLARE @Taxa DECIMAL(10, 6) = 0.10;
    DECLARE @VPL DECIMAL(18, 2);
    DECLARE @Delta DECIMAL(10, 6);
    DECLARE @Iteracao INT = 0;

    WHILE @Iteracao < @IteracoesMaximas
    BEGIN
        SET @VPL = 0;
        SELECT @VPL = @VPL + (Valor / POWER(1 + @Taxa, Periodo))
        FROM @FluxosCaixa;

        SET @VPL = @VPL - @InvestimentoInicial;

        IF ABS(@VPL) < @Precisao BREAK;

        DECLARE @VPLDerivada DECIMAL(18, 2) = 0;
        SELECT @VPLDerivada = @VPLDerivada + (-Periodo * Valor / POWER(1 + @Taxa, Periodo + 1))
        FROM @FluxosCaixa;

        IF ABS(@VPLDerivada) < @Precisao BREAK;

        SET @Delta = @VPL / @VPLDerivada;
        SET @Taxa = @Taxa - @Delta;

        SET @Iteracao = @Iteracao + 1;
    END;

    SET @TIR = @Taxa;
END;
GO
