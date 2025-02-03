# Caminho do arquivo CSV contendo a lista de hosts
$caminhoCSV = "C:\caminho\para\lista_hosts.csv"

# Defina a data a partir da qual os perfis serão excluídos (formato: MM/dd/yyyy)
$dataLimite = [datetime]::ParseExact("10/01/2023", "MM/dd/yyyy", $null)

# Importa a lista de hosts do arquivo CSV
$hosts = Import-Csv -Path $caminhoCSV

# Listas para armazenar resultados
$sucesso = @()
$falha = @()

# Loop através de cada host na lista
foreach ($host in $hosts) {
    $nomeHost = $host.HostName  # Assume que o arquivo CSV tem uma coluna chamada "HostName"

    Write-Host "Conectando ao host: $nomeHost"

    try {
        # Executa o script remotamente no host
        Invoke-Command -ComputerName $nomeHost -ScriptBlock {
            param($dataLimite)

            # Obtém todos os perfis de usuário no sistema
            $perfis = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.LocalPath -and $_.Special -eq $false }

            foreach ($perfil in $perfis) {
                # Obtém a data de criação do perfil
                $dataCriacao = [datetime]::ParseExact($perfil.Loaded, "yyyyMMddHHmmss.ffffff-000", $null)

                # Verifica se o perfil é de domínio (SID não começa com S-1-5-21)
                if ($perfil.SID -notlike "S-1-5-21-*") {
                    # Verifica se o perfil foi criado após a data limite
                    if ($dataCriacao -gt $dataLimite) {
                        $caminhoPerfil = $perfil.LocalPath
                        Write-Host "Removendo perfil de domínio no host $($env:COMPUTERNAME): $caminhoPerfil (Criado em: $dataCriacao)"

                        # Remove o perfil
                        $perfil.Delete()
                    }
                }
            }

            Write-Host "Limpeza de perfis de domínio concluída no host $($env:COMPUTERNAME)."
        } -ArgumentList $dataLimite -ErrorAction Stop

        # Adiciona o host à lista de sucesso
        $sucesso += $nomeHost
    }
    catch {
        # Adiciona o host à lista de falha e exibe o erro
        $falha += $nomeHost
        Write-Host "Erro ao conectar ou executar no host $nomeHost: $_"
    }
}

# Exibe os resultados
Write-Host "`nProcesso de limpeza remota concluído.`n"

Write-Host "Computadores com sucesso:"
$sucesso | ForEach-Object { Write-Host "- $_" }

Write-Host "`nComputadores com falha:"
$falha | ForEach-Object { Write-Host "- $_" }