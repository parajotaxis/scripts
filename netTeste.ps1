# Definir variáveis
$sourceFile = "D:\temp\CADe_SIMU\CADe_SIMU.lnk" # Caminho do arquivo de origem
$csvFilePath = "D:\Scripts\labinfo1.csv" # Caminho para o arquivo CSV
$destinationFolder = "C$\Users\Public\Desktop" # Caminho do destino nos computadores remotos
$prefix = "ZN" # Prefixo para os nomes dos computadores

# Verificar se o arquivo de origem existe
if (-Not (Test-Path -Path $sourceFile)) {
    Write-Host "Arquivo de origem não encontrado: $sourceFile" -ForegroundColor Red
    exit
}

# Verificar se o arquivo CSV existe
if (-Not (Test-Path -Path $csvFilePath)) {
    Write-Host "Arquivo CSV não encontrado: $csvFilePath" -ForegroundColor Red
    exit
}

# Ler a lista de computadores do arquivo CSV
$computers = Get-Content -Path $csvFilePath

# Contadores para acompanhamento
$successCount = 0
$failureCount = 0

# Arrays para registrar os resultados
$successfulComputers = @()
$failedComputers = @()

# Loop através da lista de computadores
foreach ($computer in $computers) {
    $computerWithPrefix = "$prefix$computer" # Adicionar o prefixo ao nome do computador
    Write-Host "Conectando ao computador: $computerWithPrefix" -ForegroundColor Cyan

    # Testar conectividade com o computador remoto
    if (Test-Connection -ComputerName $computerWithPrefix -Count 1 -Quiet) {
        # Construir o caminho do destino remoto
        $remotePath = "\\$computerWithPrefix\$destinationFolder"

        # Verificar se o destino remoto existe
        if (-Not (Test-Path -Path $remotePath)) {
            Write-Host "Criando o diretório no computador remoto: $remotePath" -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $remotePath -Force | Out-Null
        }

        $successCount++
        $successfulComputers += $computerWithPrefix
                
    } else {
        Write-Host "Não foi possível conectar ao computador: $computerWithPrefix" -ForegroundColor Red
        
        # Registrar falha
        $failureCount++
        $failedComputers += $computerWithPrefix
    }
}

# Exibir o resumo final
Write-Host "Processo concluído!" -ForegroundColor Cyan
Write-Host "Computadores bem-sucedidos: $successCount" -ForegroundColor Green
if ($successCount -gt 0) {
    Write-Host "Lista de computadores que conectaram com sucesso:" -ForegroundColor Green
    $successfulComputers | ForEach-Object { Write-Host $_ -ForegroundColor Green }
}
Write-Host "Computadores com falha: $failureCount" -ForegroundColor Red
if ($failureCount -gt 0) {
    Write-Host "Lista de computadores que não conectaram com sucesso:" -ForegroundColor Red
    $failedComputers | ForEach-Object { Write-Host $_ -ForegroundColor Red }
}