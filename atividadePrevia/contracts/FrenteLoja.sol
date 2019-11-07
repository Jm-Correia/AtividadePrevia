pragma solidity >=0.4.21 <0.6.0;

contract FrenteLoja {

    
    struct Produto{
        uint codBar;
        string descricao;
        uint preco;
        uint8 quantidade;
    }

    struct Venda{
        uint codProduto;
        uint timestamp;
        address buyer;
        
    }

    mapping (uint => Produto) produtos;
    mapping (bytes32 => Venda) public vendas;
    address payable owner;
    uint valoresVendas;

    constructor () public {
        owner = msg.sender;
        valoresVendas = 0;
    }

    function addProdutos(uint bar, string memory des, uint preco, uint8 qtd) public returns(bool) {
        require(msg.sender == owner," Vc não é Dono para incluir Protudos!!!");
       produtos[bar] = (Produto(bar, des, preco, qtd));
        return true;
    }

    function comprarProduto(uint bar, uint8 qtd) public payable returns(bytes32){
      
      if(qtd > produtos[bar].quantidade){
          revert("Quantidade indisponivel no momento!!!");
      }
      require(produtos[bar].preco * qtd == msg.value, "O valor informado se encontra está errado!!!");
      valoresVendas +=  msg.value;
      produtos[bar].quantidade -= qtd;
      bytes32 ven = keccak256(abi.encodePacked(msg.sender, bar, block.timestamp, qtd));
      vendas[ven] = (Venda(bar, block.timestamp, msg.sender));
      return ven;
    }
    
    function getNameProduto(uint codBar) public view returns(string memory){
        return produtos[codBar].descricao;
    }
    
      function transferirFunds() public{
        require(msg.sender == owner, "Vc não possui permissão para sacar!!!");
        owner.transfer(valoresVendas);
        valoresVendas = 0;
        
    }
   
}