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
