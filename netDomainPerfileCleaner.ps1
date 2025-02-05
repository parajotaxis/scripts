# Definir variáveis
$csvFilePath = "D:\Scripts\labinfo1Unico.csv" # Caminho para o arquivo CSV
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

    try {
        # Executa o script remotamente no host
        Invoke-Command -ComputerName $nomeHost -ScriptBlock {
            param($dataLimite)

            # Obtém todos os perfis de usuário no sistema
            $perfis = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.LocalPath -and $_.Special -eq $false }

            foreach ($perfil in $perfis) {

                # Verifica se o perfil é de domínio (SID não começa com S-1-5-21-234021336-877152602-)
                if ($perfil.SID - "S-1-5-21-234021336-877152602-3426630572-218607") {                    
                        $caminhoPerfil = $perfil.LocalPath
                        Write-Host "Removendo perfil de domínio no host $($env:COMPUTERNAME): $caminhoPerfil (SID: $($perfil.SID))"
                        # Remove o perfil
                        $perfil.Delete()
                }
            }

            Write-Host "Limpeza de perfis de domínio concluída no host $($env:COMPUTERNAME)."
        } -ErrorAction Stop

        # Adiciona o host à lista de sucesso
        $sucesso += $nomeHost
    }
    catch {
        # Adiciona o host à lista de falha e exibe o erro
        $falha += $nomeHost
        Write-Host "Erro ao conectar ou executar no host {$nomeHost}"
    }
}

# Exibe os resultados
Write-Host "`nProcesso de limpeza remota concluído.`n"

Write-Host "Computadores com sucesso:"
$sucesso | ForEach-Object { Write-Host "- $_" }

Write-Host "`nComputadores com falha:"
$falha | ForEach-Object { Write-Host "- $_" }