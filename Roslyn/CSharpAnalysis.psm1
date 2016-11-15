param($rootPath=$PSScriptRoot)

function LoadLibs
{
    [Reflection.Assembly]::LoadWithPartialName('Microsoft.Build')
    [Reflection.Assembly]::LoadWithPartialName('Microsoft.Build.Framework')
    [Reflection.Assembly]::LoadWithPartialName('Microsoft.Build.Tasks.Core')
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\System.Reflection.Metadata.dll")
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\Microsoft.CodeAnalysis.dll") | Out-Null
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\Microsoft.CodeAnalysis.CSharp.dll") | Out-Null
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\Microsoft.CodeAnalysis.CSharp.Workspaces.dll") | Out-Null
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\Microsoft.CodeAnalysis.Workspaces.dll") | Out-Null
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\Microsoft.CodeAnalysis.Workspaces.Desktop.dll") | Out-Null
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\System.Composition.TypedParts.dll") | Out-Null
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\System.Composition.Hosting.dll") | Out-Null
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\System.Composition.Runtime.dll") | Out-Null
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\System.Composition.AttributedModel.dll") | Out-Null
    [Reflection.Assembly]::LoadFile("$rootPath\Libs\System.Composition.Convention.dll") | Out-Null
}

LoadLibs

function Get-Classes
{
    param($file)

    $file=Get-Item $file

    $codeText=[IO.File]::ReadAllText( $file.FullName )
   
    $root=[Microsoft.CodeAnalysis.CSharp.Syntax.CompilationUnitSyntax]([Microsoft.CodeAnalysis.CSharp.CSharpSyntaxTree]::ParseText($codeText).GetRoot())

    $root.DescendantNodes()|where {$_ -is [Microsoft.CodeAnalysis.CSharp.Syntax.ClassDeclarationSyntax]} | %{
        $class=$_
        
        $methods=New-Object -Type System.Collections.ArrayList
        $class.DescendantNodes()|where {$_ -is [Microsoft.CodeAnalysis.CSharp.Syntax.MethodDeclarationSyntax] } | %{
            $method=$_
            $methodObject=[PSCustomObject]@{Name=$method.Identifier.Text;ReturnType=$method.Type.ToFullString();Raw=$method}
            $methods.Add($methodObject)|Out-Null
        }
        $properties=New-Object -Type System.Collections.ArrayList
        $class.DescendantNodes()|where {$_ -is [Microsoft.CodeAnalysis.CSharp.Syntax.PropertyDeclarationSyntax] } | %{
            $property=$_
            $propertyObject=[PSCustomObject]@{Name=$property.Identifier.Text;Type=$property.Type.ToFullString();Raw=$property}
            $properties.Add($propertyObject) |Out-Null
        }
        [PSCustomObject]@{Name=$class.Identifier.Text;Raw=$class;Methods=$methods;Properties=$properties}
    }
}


Export-ModuleMember -Function Get-*
