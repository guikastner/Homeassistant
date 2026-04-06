# Infraestrutura base para Home Assistant com Node-RED

## Objetivo

Este repositório define uma base de infraestrutura em OpenTofu para publicar:

1 - Home Assistant
2 - Node-RED
3 - túnel Cloudflare
4 - apenas serviços auxiliares estritamente necessários para a operação

O objetivo principal é manter uma base simples, reproduzível e segura para automações residenciais, sem incluir componentes que não estejam claramente dentro desse escopo.

## Princípios do projeto

1 - Todo provisionamento deve ser definido via OpenTofu.
2 - O repositório deve permanecer pequeno, direto e fácil de manter.
3 - Novos componentes só devem ser adicionados quando forem necessários ao funcionamento do Home Assistant, do Node-RED ou da publicação via Cloudflare.
4 - Defaults úteis podem existir no código, mas toda personalização operacional relevante deve poder ser controlada por variáveis.
5 - O estado desejado da infraestrutura deve ser refletido no código e no README.

## Escopo atual esperado

### Serviços

O projeto deve manter:

1 - um container Home Assistant
2 - um container Node-RED
3 - um container `cloudflared`
4 - rede Docker interna para comunicação privada entre serviços
5 - volumes persistentes para Home Assistant e Node-RED


## OpenTofu

Toda a administração do provisionamento deve ser planejada pelo OpenTofu.

### Variáveis

Todas as variáveis operacionais devem ser ajustadas em arquivo `tfvars`.

As variáveis mínimas esperadas para operação incluem:

1 - `base_domain`
2 - `timezone`
3 - `name_prefix`
4 - `network_name`
5 - `home_assistant_name`
6 - `home_assistant_hostname`
7 - `home_assistant_trusted_proxies`
8 - `node_red_hostname`
9 - `node_red_admin_password`
10 - `node_red_credential_secret`
11 - `cloudflare_api_token`
12 - `cloudflare_zone_id`
13 - `cloudflare_tunnel.name`
14 - `cloudflare_tunnel.account_id`

### Outputs

Os outputs do OpenTofu devem permanecer úteis para operação humana após o `apply`.

Eles devem priorizar:

1 - URLs finais de acesso
2 - hostnames públicos
3 - nomes de containers
4 - diretórios persistentes
5 - identificadores do túnel Cloudflare
6 - caminhos de arquivos gerados

## Home Assistant

O Home Assistant deve ser provisionado com:

1 - persistência de dados
2 - publicação externa via Cloudflare
3 - acesso de usuários apenas pelos CNAMEs publicados
4 - acesso à rede do host para integração com dispositivos físicos
5 - configuração HTTP compatível com proxy reverso
6 - configuração mínima e previsível

O projeto deve evitar complexidade prematura para o Home Assistant. Caso alguma integração futura exija `host network`, multicast, mDNS, USB passthrough ou privilégios extras, isso deve ser tratado como mudança deliberada e documentada.

## Node-RED

O Node-RED deve ser provisionado para automações integradas ao Home Assistant.

Regras esperadas:

1 - persistência de dados
2 - autenticação administrativa habilitada
3 - senha administrativa informada em texto puro no `tfvars`
4 - hash da senha gerado durante o deploy
5 - suporte à instalação de módulos extras via variável
6 - publicação externa via Cloudflare

## Rede

A topologia de rede deve continuar simples.

Regras:

1 - deve existir rede Docker interna para tráfego privado
2 - o nome dessa rede deve ser definido por variável no `tfvars`
3 - Node-RED e `cloudflared` devem ser ligados a essa rede interna
4 - o Home Assistant deve ter acesso à rede do host para descoberta e integração com dispositivos
5 - containers devem se comunicar entre si apenas pela rede do projeto, exceto o Home Assistant quando precisar usar a rede do host
6 - usuários devem acessar os serviços pelos CNAMEs publicados
7 - o uso de `host network` deve ficar restrito ao Home Assistant, salvo decisão técnica futura

## Cloudflare

O Home Assistant e o Node-RED devem ser publicados no Cloudflare.

Regras obrigatórias:

1 - deve existir um CNAME para Home Assistant
2 - deve existir um CNAME para Node-RED
3 - ambos devem ser configuráveis via variáveis
4 - o túnel deve ser criado e configurado pelo OpenTofu
5 - ingress e DNS devem permanecer coerentes entre si

Os hostnames públicos configuráveis devem continuar separados dos nomes internos dos containers.

## Persistência

Os serviços devem ter volumes persistentes.

Regras:

1 - Home Assistant deve persistir `/config`
2 - Node-RED deve persistir `/data`
3 - o `configuration.yaml` base do Home Assistant deve ser gerado pela codebase
4 - arquivos mínimos incluídos pelo Home Assistant devem existir no primeiro boot
5 - diretórios gerados localmente devem ser previsíveis
6 - `destroy` deve remover os dados persistentes e os arquivos gerados quando `delete_data_on_destroy = true`
7 - o comportamento padrão esperado desta base é destruir também os dados locais da stack

## Git e segurança

Sempre proteger secrets e senhas no `gitignore` e manter credenciais reais fora do repositório quando possível.

Regras mínimas:

1 - ignorar `tfvars`, estado e diretórios locais do OpenTofu
2 - não commitar credenciais reais em exemplos
3 - evitar manter segredos renderizados versionados
4 - manter `.terraform.lock.hcl` versionável
5 - qualquer mudança que aumente superfície de exposição deve ser revisada

## README

O `README` deve sempre ser atualizado em inglês.

Ele deve refletir:

1 - escopo atual do projeto
2 - variáveis relevantes
3 - comportamento de rede
4 - publicação via Cloudflare
5 - fluxo de senha do Node-RED
6 - limites conhecidos da base atual

## Critérios para futuras mudanças

Antes de adicionar algo novo, validar:

1 - isso serve diretamente ao Home Assistant, Node-RED ou Cloudflare?
2 - isso precisa mesmo estar nesta base?
3 - isso aumenta manutenção sem ganho operacional claro?
4 - isso exige nova variável, novo output ou atualização do README?
5 - isso altera segurança, rede ou persistência?

Se a resposta indicar aumento de complexidade sem benefício claro, a mudança não deve entrar.
