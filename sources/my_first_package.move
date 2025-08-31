/// ---------------------------------------------------------------------------
/// Módulo de exemplo para criar e gerenciar um NFT simples no Sui.
/// Aqui mostramos como declarar estruturas, inicializar um Publisher
/// e expor entry functions para "mintar" NFTs.
/// ---------------------------------------------------------------------------
module my_first_package::meu_primeiro_nft {
    // --- IMPORTAÇÕES NECESSÁRIAS ---

    // Para trabalhar com exibição (Display) do NFT em carteiras/exploradores.
    use sui::display;

    // Para manipular strings.
    use std::string::{Self, String};

    // Para obter Publisher, usado para criar/alterar Displays.
    use sui::package::{Self, Publisher};

    // Para criar/transacionar objetos.
    use sui::object;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;


    // --- DEFINIÇÃO DOS OBJETOS ---

    /// One-Time Witness (OTW) - usado para registrar nosso módulo na blockchain.
    /// Ele só existe no momento da publicação e garante unicidade do Publisher.
    public struct MEU_PRIMEIRO_NFT has drop {}

    /// Estrutura principal do NFT.
    /// - `has key`: permite que seja um objeto armazenado on-chain e com dono.
    /// - `has store`: permite que seja usado dentro de outras estruturas.
    public struct MeuPrimeiroNFT has key, store {
        id: UID,               // Identificador único do objeto (todo objeto precisa de 1 UID).
        titulo: String,        // Nome ou título do NFT.
        descricao: String,     // Descrição curta.
        imagem_url: String     // URL da imagem associada (ex: IPFS ou link público).
    }


    // --- FUNÇÕES DE INICIALIZAÇÃO ---

    /// Função `init` é chamada automaticamente **uma vez** ao publicar o módulo.
    /// Cria o Publisher para o tipo `MeuPrimeiroNFT`.
    fun init(otw: MEU_PRIMEIRO_NFT, ctx: &mut TxContext) {
        // Cria um objeto Publisher exclusivo para o nosso tipo NFT.
        let publisher = package::claim(otw, ctx);

        // Transfere o Publisher para o dono do contrato (quem publicou o módulo).
        transfer::public_transfer(publisher, tx_context::sender(ctx));
    }


    // --- ENTRY FUNCTIONS PÚBLICAS ---

    /// Função para criar ("mintar") um novo NFT e enviá-lo para a carteira do chamador.
    entry fun mint(
        titulo: vector<u8>,        // Nome/título do NFT em bytes.
        descricao: vector<u8>,     // Descrição em bytes.
        imagem_url: vector<u8>,    // URL da imagem em bytes.
        ctx: &mut TxContext        // Contexto da transação (sempre obrigatório).
    ) {
        // Constrói o objeto NFT com os dados fornecidos.
        let nft = MeuPrimeiroNFT {
            id: object::new(ctx),                          // Cria o UID automaticamente.
            titulo: string::utf8(titulo),                  // Converte vector<u8> para String.
            descricao: string::utf8(descricao),
            imagem_url: string::utf8(imagem_url),
        };

        // Transfere o NFT recém-criado para a carteira que chamou a função.
        transfer::public_transfer(nft, tx_context::sender(ctx));
    }

    /// Função para criar o "Display" que define como nosso NFT será exibido.
    /// Deve ser chamada apenas UMA VEZ após o deploy do módulo.
    entry fun create_display(
        publisher: &Publisher,      // Prova de autoridade (recebida no `init`).
        ctx: &mut TxContext
    ) {
        // Cria o Display com mapeamento dos campos para exibição.
        let mut display = display::new_with_fields<MeuPrimeiroNFT>(
            publisher,
            // Campos que queremos mostrar (nomes legíveis).
            vector[
                string::utf8(b"titulo"),
                string::utf8(b"descricao"),
                string::utf8(b"image_url")  // Nome padrão reconhecido para imagens!
            ],
            // Valores correspondentes aos campos.
            vector[
                string::utf8(b"{titulo}"),
                string::utf8(b"{descricao}"),
                string::utf8(b"{imagem_url}")  // Mapeia nosso campo `imagem_url` para "image_url".
            ],
            ctx
        );

        // Ativa o Display atualizando sua versão.
        display::update_version(&mut display);

        // Transfere o Display para a carteira que chamou.
        transfer::public_transfer(display, tx_context::sender(ctx));
    }
}
