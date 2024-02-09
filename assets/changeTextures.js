let material;
let saveTexture;
let input;

      const createAndApplyTexture = async (channel, file) => {
        const texture = await modelViewerTexture.createTexture(file);
        if (channel.includes('base') || channel.includes('metallic')) {
          material.pbrMetallicRoughness[channel].setTexture(texture);
        } else {
          material[channel].setTexture(texture);
        }
      }

      function changeTexture(changeValue){
      console.log("In Change Texture");
      if(changeValue.includes('Default')){
        material.pbrMetallicRoughness['baseColorTexture'].setTexture(saveTexture);
      }else{
        createAndApplyTexture('baseColorTexture', changeValue);
       }
      }

const modelViewerTexture = document.querySelector("model-viewer#model");
        console.log("Found MODEl VIEWER!");
     modelViewerTexture.addEventListener("load", () => {
     material = modelViewerTexture.model.materials[0];
     saveTexture = material.pbrMetallicRoughness['baseColorTexture'].texture;

});