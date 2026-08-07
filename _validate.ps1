$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile('C:/Users/Acid/Documents/repo/Awesome-Vivaldi/install.ps1', [ref]$null, [ref]$errors)
Write-Host "Parse errors: $($errors.Count)"
$funcs = $ast.FindAll({param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)
Write-Host "Functions: $($funcs.Count)"
$funcs | ForEach-Object { Write-Host "  $($_.Name) (line $($_.Extent.StartLineNumber))" }
