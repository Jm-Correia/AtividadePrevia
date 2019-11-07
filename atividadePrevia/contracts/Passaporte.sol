pragma solidity >=0.4.21 <0.6.0;
contract Passaporte {
    
    enum PAISES {BRAZIL, EUA, CANADA, ARGENTINA, CHILE, CHINA, AUSTRALIA}
    enum TIPOCARIMBO {ENTRADA, SAIDA}
    
    struct Carimbo {
        uint dtCarimbo;
        PAISES sigla;
        TIPOCARIMBO tipo;
    }

    struct Documento_Pass {
        uint dtEmissao;
        uint8 validadeAnos;
        string primeiroNome;
        string ultimoNome;
        PAISES pais; 
        Carimbo[] carimbos;
        address pessoa;
    }
    
    address payable emissor;
    uint pagamentos;
    
    mapping(address => Documento_Pass) documentos;
    address[] passaportes;
    
    constructor () public{
        emissor = msg.sender;
        pagamentos = 0;
    }
    
    function emitirPrimeiroPassaporte(string memory Name, string  memory lastName, PAISES pais) public payable returns(bytes32){
        require(msg.value == 2 ether, "Valor Insuficiente para emitir o passaporte!!!");
        require(verificarDoc(),"Você já possui passaporte, caso esteja vencido por favor renove seu Passaporte!!!");
        
         pagamentos += msg.value;
         
         Documento_Pass storage doc = documentos[msg.sender];
         doc.dtEmissao = block.timestamp;
         doc.validadeAnos = 10;
         doc.primeiroNome = Name;
         doc.ultimoNome = lastName;
         doc.pais = PAISES(pais);
         doc.pessoa = msg.sender;
        
        passaportes.push(msg.sender)-1;
        
         return keccak256(abi.encodePacked(block.timestamp, msg.sender, pais, Name, lastName));
    }
    
    function solicitarEntradaPais(uint pais) public payable returns(bool){
        require(msg.value == 100000 wei, "Valor Insuficiente para entrada neste País!!!");
        pagamentos += msg.value;
        
        carimbarFolha(msg.sender, PAISES(pais), TIPOCARIMBO.ENTRADA);
        
        return true;
    }
    
    function solicitarSaidaPais() public returns(bool){
        Documento_Pass storage doc = documentos[msg.sender];
        
        //PAISES p = doc.carimbos[doc.carimbos.length-1].sigla;
        PAISES p = doc.carimbos[doc.carimbos.length-1].sigla;
      
        
        carimbarFolha(msg.sender, p, TIPOCARIMBO.SAIDA);
        
        return true;
    }
    
    
    function carimbarFolha(address viajante, PAISES pais, TIPOCARIMBO tipo) internal{
        documentos[viajante].carimbos.push(Carimbo(block.timestamp, pais, tipo));
    }
    
    function sacarFunds () public {
        require(msg.sender == emissor, "Apenas o emissor poderá sacar!!!");
        emissor.transfer(pagamentos);
        pagamentos = 0;
    }

    function verificarDoc() public view returns(bool){
        for(uint i= 0; i < passaportes.length; i++){
             if(passaportes[i] == msg.sender){ 
                 return true;
             }
        }
        return false;
    } 
    
    function exibirCarimbos(uint a) public view returns(uint, PAISES) {
            
        require(documentos[msg.sender].carimbos.length != 0, "Vc ainda não possui carimbos!!!!");
        Documento_Pass storage doc = documentos[msg.sender];
        return (doc.carimbos[a].dtCarimbo, doc.carimbos[a].sigla);
    }

}

