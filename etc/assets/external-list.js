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
      if(changeValue.includes('Default')){
        material.pbrMetallicRoughness['baseColorTexture'].setTexture(saveTexture);
      }else{
        createAndApplyTexture('baseColorTexture', changeValue);
       }
      }

const modelViewerTexture = document.querySelector("model-viewer#model");
    modelViewerTexture.addEventListener("load", () => {
     material = modelViewerTexture.model.materials[0];
     saveTexture = material.pbrMetallicRoughness['baseColorTexture'].texture;
     input = document.querySelector('#variant');

      input.addEventListener('change', () => {
        console.log(input.value);
        changeTexture(input.value);
      });

      /*
      fetch('./additionalTextures.json')
        .then(response => response.json())
        .then(data => {
          for (let index = 0; index < data.length; index++) {
            const nameOfTexture = data[index].name;
            const pathToTexture = data[index].path;
            let option = document.createElement('option');
            option.text = data[index].name;
            option.value = data[index].path;
            input.add(option);
          }

        })
        .catch(error => console.log(error));
      */
    });