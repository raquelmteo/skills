-- Alterar o nome do banco de dados de AdventureWorksDW2020 para AdventureWorks
ALTER DATABASE AdventureWorksDW2020 MODIFY NAME = AdventureWorks;

-- Atualizar o valor da coluna BusinessType na tabela DimReseller para 'Warehouse' onde o valor atual é 'Ware House'
UPDATE DimReseller
SET BusinessType = 'Warehouse'
WHERE BusinessType = 'Ware House';

-- Atualizar a coluna TotalProductCost na tabela FactResellerSales com o custo total do produto (OrderQuantity * StandardCost)
-- Utiliza um JOIN com a tabela DimProduct para obter o StandardCost de cada produto
-- Atualiza apenas onde TotalProductCost está nulo ou vazio
UPDATE FactResellerSales
SET TotalProductCost = cast(OrderQuantity as decimal) * cast(DimProduct.StandardCost as decimal)
FROM FactResellerSales
JOIN DimProduct ON FactResellerSales.ProductKey = DimProduct.ProductKey
WHERE TotalProductCost IS NULL OR TotalProductCost like '';

-- Inserir uma nova linha na tabela DimProductCategory com o valor 'internal_use' em várias colunas
INSERT INTO DimProductCategory ([EnglishProductCategoryName],[SpanishProductCategoryName],[FrenchProductCategoryName])
VALUES ('internal_use', 'internal_use', 'internal_use');

-- Inserir uma nova linha na tabela DimProductSubCategory com valores 'internal_use' e ProductCategoryKey 5
INSERT INTO DimProductSubCategory ([EnglishProductSubCategoryName],[SpanishProductSubCategoryName],[FrenchProductCategoryName],[ProductCategoryKey])
VALUES ('internal_use', 'internal_use', 'internal_use',5);

-- Atualizar a coluna ProductSubcategoryKey na tabela DimProduct para 38 onde o valor é NULL ou vazio
UPDATE [dbo].[DimProduct]
SET [ProductSubcategoryKey] = 38
WHERE [ProductSubcategoryKey] IS NULL OR [ProductSubcategoryKey] like '';

-- Atualizar as colunas SpanishProductName e FrenchProductName com o valor da coluna EnglishProductName
-- Onde SpanishProductName ou FrenchProductName estão nulos ou vazios
UPDATE [dbo].[DimProduct]
SET [SpanishProductName] = [EnglishProductName], [FrenchProductName] = [EnglishProductName]
WHERE [SpanishProductName] IS NULL OR [SpanishProductName] like '' OR [FrenchProductName] IS NULL OR [FrenchProductName] like '';

-- Seleciona informações do cliente para produtos de uma categoria específica
SELECT Title, FirstName, LastName, Phone 
FROM [DimCustomer]
INNER JOIN [FactInternetSales] ON [DimCustomer].[CustomerKey] = [FactInternetSales].[CustomerKey]
INNER JOIN [DimProduct] ON [FactInternetSales].[ProductKey] = [DimProduct].[ProductKey]
INNER JOIN [DimProductSubcategory] ON [DimProduct].[ProductSubcategoryKey] = [DimProductSubcategory].[ProductSubcategoryKey]
INNER JOIN [DimProductCategory] ON [DimProductSubcategory].[ProductCategoryKey] = [DimProductCategory].[ProductCategoryKey]
-- Filtra apenas os produtos da categoria onde ProductCategoryKey é 1
WHERE [DimProductCategory].[ProductCategoryKey] = 1;

-- Seleciona informações detalhadas dos clientes do sexo feminino
SELECT Title, FirstName, LastName, BirthDate, EmailAddress, AddressLine1, AddressLine2, Phone, DateFirstPurchase 
FROM [DimCustomer]
-- Filtra apenas clientes do sexo feminino
WHERE Gender = 'F';

-- Cria uma view chamada TopOnlineSubcategories para ver as 5 subcategorias com maiores vendas
CREATE VIEW TopOnlineSubcategories AS
SELECT TOP 5 DimProductSubcategory.[EnglishProductSubcategoryName], 
       SUM(FactInternetSales.[SalesAmount]) AS TotalSales
-- Faz join para relacionar DimProduct com suas subcategorias e as vendas
FROM DimProduct
JOIN DimProductSubcategory ON DimProduct.[ProductSubcategoryKey] = DimProductSubcategory.[ProductSubcategoryKey]
JOIN FactInternetSales ON DimProduct.[ProductKey] = FactInternetSales.[ProductKey]
-- Agrupa pelas subcategorias e soma o total de vendas para cada uma
GROUP BY DimProductSubcategory.[EnglishProductSubcategoryName]
-- Ordena pelo total de vendas em ordem decrescente e retorna as 5 primeiras
ORDER BY TotalSales DESC;

-- Remove a view Onlinecategories caso ela já exista
DROP VIEW Onlinecategories;

-- Cria uma view chamada Onlinecategories para ver o total de vendas por categoria de produto
CREATE VIEW Onlinecategories AS
SELECT DimProductCategory.EnglishProductCategoryName, 
       SUM(FactInternetSales.SalesAmount) AS TotalSales
-- Faz joins para relacionar DimProduct com sua categoria e subcategoria, e com as vendas
FROM DimProduct
JOIN DimProductSubcategory ON DimProduct.ProductSubcategoryKey = DimProductSubcategory.ProductSubcategoryKey
JOIN DimProductCategory ON DimProductSubcategory.ProductCategoryKey = DimProductCategory.ProductCategoryKey
JOIN FactInternetSales ON DimProduct.ProductKey = FactInternetSales.ProductKey
-- Agrupa pelo nome da categoria e soma o total de vendas para cada uma
GROUP BY DimProductCategory.EnglishProductCategoryName;

-- Cria um trigger trg_Products que executa após a inserção na tabela DimProduct
CREATE TRIGGER trg_Products
ON DimProduct
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON; -- Evita mensagens de contagem de linhas
  
  -- Declara uma variável para armazenar o ProductKey do registro recém-inserido
  DECLARE @ProductKey VARCHAR(50) = (SELECT ProductKey FROM inserted);
  -- Define a data de hoje para ser usada no EndDate
  DECLARE @Today DATETIME = GETDATE();

  -- Verifica se o ProductKey inserido já existe em DimProduct
  IF EXISTS(SELECT 1 FROM DimProduct WHERE ProductKey = @ProductKey)
  BEGIN
    -- Atualiza o status e a data de término dos produtos anteriores (status = 'Current')
    -- onde o ProductAlternateKey corresponde e a data de início é anterior a hoje
    UPDATE DimProduct 
    SET Status = NULL, EndDate = @Today 
    WHERE ProductAlternateKey = @ProductKey 
      AND Status = 'Current' 
      AND StartDate < @Today;

    -- Se mais de uma linha foi atualizada, imprime uma mensagem
    IF @@ROWCOUNT > 1
      PRINT 'Multiple rows were updated by the trigger.';
  END
END;

-- Import data from CSV file
BULK INSERT Customer
FROM 'C:\ExportedData\Export_Costumer.csv'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '\n',FIRSTROW = 2,  KEEPIDENTITY);

-- Import data from CSV file
BULK INSERT [Date]
FROM 'C:\ExportedData\Export_Date.csv'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '\n',FIRSTROW = 2,  KEEPIDENTITY);

-- Import data from CSV file
BULK INSERT Product
FROM 'C:\ExportedData\Export_Products.csv'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '\n',FIRSTROW = 2,  KEEPIDENTITY);

-- Import data from CSV file
BULK INSERT Store
FROM 'C:\ExportedData\Export_Stores.csv'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '\n',FIRSTROW = 2,  KEEPIDENTITY);

-- Import data from CSV file
BULK INSERT Orders
FROM 'C:\ExportedData\Export_Orders.csv'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '\n',FIRSTROW = 2,  KEEPIDENTITY);

-- Import data from CSV file
BULK INSERT OrderRows
FROM 'C:\ExportedData\Export_OrderRows.csv'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '\n',FIRSTROW = 2,  KEEPIDENTITY);

-- Adiciona colunas calculadas na tabela [date]
ALTER TABLE [date]
ADD 
    -- Adiciona a coluna MonthKey que converte o valor da coluna [date] para o formato YYYYMM
    MonthKey AS CONVERT(VARCHAR(8), CONVERT(DATE, [date], 105), 112) PERSISTED, 
    
    -- Adiciona a coluna Year que extrai o ano da coluna [date]
    [Year] AS YEAR([date]) PERSISTED,
    
    -- Adiciona a coluna Quarter que extrai o trimestre do ano a partir da coluna [date]
    [Quarter] AS DATEPART(QUARTER, [date]) PERSISTED,
    
    -- Adiciona a coluna Month que extrai o número do mês (1 a 12) da coluna [date]
    [Month] AS MONTH([date]) PERSISTED,
    
    -- Adiciona a coluna MonthName que extrai o nome do mês da coluna [date] 
    -- e o converte para uma string de até 10 caracteres
    [MonthName] AS CAST(DATENAME(MONTH, [date]) AS VARCHAR(10)),
    
    -- Adiciona a coluna DayofMonth que extrai o dia do mês (1 a 31) da coluna [date]
    [DayofMonth] AS DAY([date]) PERSISTED,
    
    -- Adiciona a coluna DayofWeek que extrai o número do dia da semana (1 a 7) da coluna [date]
    [DayofWeek] AS DATEPART(WEEKDAY, [date]),
    
    -- Adiciona a coluna DayofWeekName que extrai o nome do dia da semana da coluna [date]
    DayofWeekName AS DATENAME(WEEKDAY, [date]);

-- Adiciona a coluna Month que extrai o número do mês (1 a 12) da coluna [date] novamente
ALTER TABLE [date] 
ADD [Month] AS MONTH([date]) PERSISTED;

-- Cria o banco de dados BrowseGadgets
CREATE DATABASE BrowseGadgets;
GO

-- Seleciona o banco de dados BrowseGadgets para uso
USE BrowseGadgets;
GO

-- Cria a tabela Customer com detalhes sobre os clientes
CREATE TABLE Customer
(
    -- Chave primária única para cada cliente, auto-incremento
    CustomerKey INT PRIMARY KEY IDENTITY,  
    
    -- Informações pessoais
    Gender NVARCHAR(10) NULL,                  -- Gênero do cliente
    Title NVARCHAR(50) NULL,                   -- Título (ex.: Sr., Sra.)
    GivenName NVARCHAR(150) NULL,              -- Primeiro nome
    MiddleInitial NVARCHAR(150) NULL,          -- Inicial do nome do meio
    Surname NVARCHAR(150) NULL,                -- Sobrenome
    
    -- Endereço e localização
    StreetAdress NVARCHAR(150) NULL,           -- Endereço completo
    City NVARCHAR(50) NULL,                    -- Cidade
    [State] NVARCHAR(50) NULL,                 -- Estado
    [StateFull] NVARCHAR(50) NULL,             -- Nome completo do estado
    ZipCode NVARCHAR(50) NULL,                 -- Código postal
    [Country] NVARCHAR(50) NULL,               -- País
    [CountryFull] NVARCHAR(50) NULL,           -- Nome completo do país
    
    -- Detalhes adicionais
    BirthDay DATETIME2(7) NULL,                -- Data de nascimento com precisão de microssegundos
    Age INT NULL,                              -- Idade
    Occupation NVARCHAR(100) NULL,             -- Ocupação
    Company NVARCHAR(50) NULL,                 -- Empresa onde trabalha
    Vehicle NVARCHAR(50) NULL,                 -- Veículo do cliente
    
    -- Coordenadas de localização
    Latitude FLOAT NULL,                       -- Latitude do endereço
    Longitude FLOAT NULL,                      -- Longitude do endereço
    
    -- Continente do cliente
    Continent NVARCHAR(50) NULL                -- Nome do continente
);

-- Cria a tabela Product com detalhes sobre produtos
CREATE TABLE Product
(
    ProductKey INT PRIMARY KEY IDENTITY,       -- Chave primária, auto-incremento
    
    -- Informações sobre o produto
    [Product Code] NVARCHAR(255) NULL,         -- Código do produto
    [Product Name] NVARCHAR(500) NULL,         -- Nome do produto
    Manufacturer NVARCHAR(50) NULL,            -- Fabricante do produto
    Brand NVARCHAR(50) NULL,                   -- Marca do produto
    Color NVARCHAR(20) NOT NULL,               -- Cor do produto
    
    -- Medidas e preços
    [Weight Unit Mesure] NVARCHAR(20),         -- Unidade de peso (ex.: kg, lbs)
    [Weight] FLOAT NULL,                       -- Peso do produto
    [Unit Cost] MONEY NULL,                    -- Custo unitário do produto
    [Unit Price] MONEY NULL,                   -- Preço unitário do produto
    
    -- Categoria e subcategoria do produto
    [Subcategory Code] NVARCHAR(100) NULL,     -- Código da subcategoria
    [Subcategory] NVARCHAR(50) NULL,           -- Nome da subcategoria
    [Category Code] NVARCHAR(100) NULL,        -- Código da categoria
    [Category] NVARCHAR(30) NULL               -- Nome da categoria
);

-- Cria a tabela Store com detalhes sobre as lojas
CREATE TABLE Store
(
    StoreKey INT PRIMARY KEY IDENTITY,         -- Chave primária, auto-incremento
    
    -- Informações da loja
    [Store Code] INT NULL,                     -- Código da loja
    [Country] NVARCHAR(50) NULL,               -- País onde está localizada
    [State] NVARCHAR(50) NULL,                 -- Estado onde está localizada
    [Name] NVARCHAR(100) NULL,                 -- Nome da loja
    [Square Meters] INT NULL,                  -- Área da loja em metros quadrados
    [Open Date] DATE NULL,                     -- Data de abertura
    [Close Date] DATE NULL,                    -- Data de fechamento (caso fechada)
    [Status] NVARCHAR(50) NULL                 -- Status da loja (ex.: ativa, fechada)
);

-- Cria a tabela Orders com detalhes sobre os pedidos
CREATE TABLE Orders
(
    OrderKey BIGINT PRIMARY KEY IDENTITY,      -- Chave primária para cada pedido, auto-incremento
    
    -- Referências de cliente e loja
    CustomerKey INT NULL,                      -- Chave estrangeira para Customer
    StoreKey INT NULL,                         -- Chave estrangeira para Store
    
    -- Datas e moeda do pedido
    [Order Date] DATE NULL,                    -- Data do pedido
    [Delivery Date] DATE NULL,                 -- Data de entrega
    [Currency Code] NCHAR(3) NULL              -- Código da moeda do pedido (ex.: USD, EUR)
);

-- Cria a tabela OrderRows com os detalhes das linhas de cada pedido
CREATE TABLE OrderRows
(
    OrderKey BIGINT NULL,                      -- Chave estrangeira para Orders
    
    -- Detalhes da linha do pedido
    [Line Number] INT NULL,                    -- Número da linha do pedido
    ProductKey INT NULL,                       -- Chave estrangeira para Product
    Quantity INT NULL,                         -- Quantidade do produto na linha
    [Unit Price] MONEY NULL,                   -- Preço unitário do produto na linha
    [Net Price] MONEY NULL,                    -- Preço total líquido do produto
    [Unit Cost] MONEY NULL                     -- Custo unitário do produto
);

-- Cria a tabela Date para armazenar datas únicas
CREATE TABLE Date
(
    [Date] DATE PRIMARY KEY                    -- Chave primária única para cada data
);

-- Atualiza o fabricante e a marca para 'Wide World Importers' onde o fabricante atual é 'Northwind Traders'
UPDATE Product
SET Manufacturer = 'Wide World Importers', Brand = 'Wide World Importers'
WHERE Manufacturer = 'Northwind Traders';

-- Atualiza o preço unitário dos produtos aplicando um aumento de 10%, arredondando o valor para 2 casas decimais
UPDATE Product
SET [Unit Price] = ROUND([Unit Price] * 1.1, 2);

-- Fecha a loja com a chave StoreKey = 190, definindo o status como 'Closed' e a data de fechamento como a data atual
UPDATE Store
SET Status = 'Closed', [Close Date] = GETDATE()
WHERE StoreKey = 190;

-- Insere uma nova loja duplicada da loja com StoreKey = 190, mas com um espaço de 2000 metros quadrados e data de abertura em 15 de maio de 2023
INSERT INTO Store ([Store Code], Country, [State], [Name], [Square Meters], [Open Date], [Close Date], [Status])
SELECT [Store Code], Country, [State], [Name], 2000, '2023/05/15', NULL, NULL
FROM Store
WHERE StoreKey = 190;

-- Seleciona todos os registros de clientes com o nome 'Abbie Carroll'
SELECT * FROM Customer WHERE GivenName = 'Abbie' AND Surname = 'Carroll';

-- Atualiza o código do cliente para 1011254 em todos os pedidos onde o cliente atual tem a chave CustomerKey = 916631
UPDATE Orders
SET CustomerKey = 1011254
WHERE CustomerKey = 916631;

-- Deleta o cliente com a chave CustomerKey = 916631 do banco de dados
DELETE FROM Customer
WHERE CustomerKey = 916631;

-- Criação da View "OrdersWithDateInfo"
CREATE VIEW OrdersWithDateInfo AS
SELECT 
  Orders.*,                  -- Seleciona todas as colunas da tabela Orders
  Date.Year,                  -- Adiciona o Ano da tabela Date
  Date.month,                 -- Adiciona o Mês da tabela Date
  Date.Quarter                -- Adiciona o Trimestre da tabela Date
FROM Orders
JOIN Date ON Orders.[Order Date] = Date.Date;  -- Realiza o JOIN entre Orders e Date, onde as datas são iguais

-- Consulta simples de dados da tabela Orders com informações de data (erro, falta JOIN)
SELECT 
  Orders.*, 
  Date.Year, 
  Date.month,
  Date.Quarter
FROM Orders;  -- Aqui falta o JOIN com a tabela Date para funcionar corretamente, o código estará com erro

-- Cálculo do total de vendas por loja e ano
SELECT
  Orders.StoreKey,                  -- Seleciona o identificador da loja (StoreKey)
  Date.Year,                         -- Adiciona o Ano da tabela Date
  SUM([Unit Price] * [Quantity]) AS TotalSales  -- Calcula o total de vendas (preço unitário * quantidade)
FROM OrderRows
INNER JOIN Orders ON OrderRows.[OrderKey] = Orders.[OrderKey]  -- Realiza JOIN entre OrderRows e Orders
INNER JOIN Date ON Orders.[Delivery Date] = Date.[Date]  -- Realiza JOIN entre Orders e Date (data de entrega)
INNER JOIN Store ON Orders.StoreKey = Store.StoreKey  -- Realiza JOIN entre Orders e Store (dados da loja)
GROUP BY Orders.StoreKey, Date.Year;  -- Agrupa os resultados por loja e ano

-- Consulta de clientes que possuem veículos fabricados antes de 2010
SELECT *
FROM Customer
WHERE CAST(SUBSTRING([Vehicle], 1, 4) AS INT) < 2010;  -- Extrai os primeiros 4 caracteres do campo Vehicle e converte para INT para comparar com 2010

-- Criação do procedimento armazenado para verificar se um produto existe
CREATE PROCEDURE CheckProductExists
    @ProductName VARCHAR(50)  -- Parâmetro de entrada para o nome do produto
AS
BEGIN
    IF EXISTS (SELECT * FROM Product WHERE [Product Name] = @ProductName)  -- Verifica se o produto existe na tabela Product
    BEGIN
        SELECT 'Product already exists' AS Result  -- Caso exista, retorna a mensagem 'Product already exists'
    END
    ELSE
    BEGIN
        SELECT 'Product does not exist' AS Result  -- Caso não exista, retorna a mensagem 'Product does not exist'
    END
END

-- Execução do procedimento para verificar a existência do produto 'Contoso 2G MP3 Player E200 Blue'
EXEC CheckProductExists 'Contoso 2G MP3 Player E200 Blue'; 

-- Criação de Trigger (gatilho) para inserir a data de hoje na tabela Date caso a data não exista
CREATE TRIGGER trg_order_Insert
ON [dbo].[Orders]  -- O trigger será ativado após inserções na tabela Orders
AFTER INSERT
AS
BEGIN
  IF NOT EXISTS (SELECT * FROM Date WHERE Date = GETDATE())  -- Verifica se a data atual (GETDATE()) já está presente na tabela Date
  BEGIN
    INSERT INTO Date ([Date])  -- Se a data não existir, insere a data atual na tabela Date
    SELECT GETDATE();  -- Insere a data atual
  END
END;

-- Adiciona uma chave estrangeira para a tabela OrderRows, referenciando a tabela Orders
ALTER TABLE OrderRows 
ADD CONSTRAINT FK_OrderRows_Orders
FOREIGN KEY (OrderKey) REFERENCES Orders (OrderKey);  -- A coluna 'OrderKey' de OrderRows será uma chave estrangeira que aponta para a coluna 'OrderKey' da tabela Orders

-- Adiciona uma chave estrangeira para a tabela OrderRows, referenciando a tabela Product
ALTER TABLE OrderRows
ADD CONSTRAINT FK_OrderRows_Product
FOREIGN KEY (ProductKey) REFERENCES Product (ProductKey);  -- A coluna 'ProductKey' de OrderRows será uma chave estrangeira que aponta para a coluna 'ProductKey' da tabela Product

-- Adiciona uma chave estrangeira para a tabela Orders, referenciando a tabela Customer
ALTER TABLE Orders
ADD CONSTRAINT FK_Order_Customer
FOREIGN KEY (CustomerKey) REFERENCES Customer (CustomerKey);  -- A coluna 'CustomerKey' de Orders será uma chave estrangeira que aponta para a coluna 'CustomerKey' da tabela Customer

-- Adiciona uma chave estrangeira para a tabela Orders, referenciando a tabela Date
ALTER TABLE Orders
ADD CONSTRAINT FK_Order_Date
FOREIGN KEY ([Order Date]) REFERENCES [Date] ([Date]);  -- A coluna 'Order Date' de Orders será uma chave estrangeira que aponta para a coluna 'Date' da tabela Date

-- Adiciona uma chave estrangeira para a tabela Orders, referenciando a tabela Store
ALTER TABLE Orders
ADD CONSTRAINT FK_Order_Store
FOREIGN KEY (StoreKey) REFERENCES Store (StoreKey);  -- A coluna 'StoreKey' de Orders será uma chave estrangeira que aponta para a coluna 'StoreKey' da tabela Store

-- Remove a restrição de chave estrangeira 'FK_Order_Store' da tabela Orders
ALTER TABLE Orders
DROP CONSTRAINT FK_Order_Store;  -- Remove a chave estrangeira que liga a coluna 'StoreKey' de Orders à tabela Store

-- Cria uma visualização (view) chamada LowStockItems
CREATE VIEW LowStockItems AS
SELECT *, [QuantityOnHand] AS CurrentStock  -- Seleciona todas as colunas da tabela StockItemHoldings e renomeia a coluna 'QuantityOnHand' para 'CurrentStock'
FROM [Warehouse].[StockItemHoldings]
WHERE [QuantityOnHand] < [TargetStockLevel];  -- Filtra os itens onde o estoque disponível (QuantityOnHand) é menor que o nível de estoque alvo (TargetStockLevel)

-- Cria uma visualização (view) chamada vEmployeeSellers
CREATE VIEW vEmployeeSellers AS
SELECT  [FullName], IsEmployee, [IsSalesperson],  -- Seleciona as colunas FullName, IsEmployee e IsSalesperson
       -- Cria uma nova coluna chamada SellerStatus que indica se a pessoa é um vendedor ou não
       CASE WHEN [IsSalesperson] = 1 THEN 'Seller' ELSE 'Not Seller' END AS SellerStatus
FROM [Application].[People_Archive]  -- Fonte de dados: tabela People_Archive do esquema Application
WHERE IsEmployee = 1;  -- Filtra os registros onde a pessoa é um empregado (IsEmployee = 1)

-- Cria um procedimento armazenado (stored procedure) chamado GetCustomerPurchases
CREATE PROCEDURE GetCustomerPurchases
    @CustomerId INT  -- Parâmetro de entrada @CustomerId que será usado para filtrar as compras do cliente
AS
BEGIN
    -- Consulta que retorna todas as compras do cliente com o CustomerID fornecido
    SELECT *
    FROM [Sales].[OrderLines]  -- Tabela OrderLines do esquema Sales que contém os itens de cada pedido
    INNER JOIN [Sales].[Orders] ON [Sales].[Orders].[OrderID] = [Sales].[OrderLines].[OrderID]  -- Faz um INNER JOIN com a tabela Orders para obter detalhes do pedido com base no OrderID
    WHERE [Sales].[Orders].[CustomerID] = @CustomerId  -- Filtra os pedidos onde o CustomerID é igual ao parâmetro fornecido
END

-- Executa o procedimento armazenado GetCustomerPurchases passando o CustomerId 890
EXECUTE GetCustomerPurchases @CustomerId = 890;
