const modelViewerTexture = document.querySelector("model-viewer#model");
    modelViewerTexture.addEventListener("load", () => {
      const material = modelViewerTexture.model.materials[0];
      const saveTexture = material.pbrMetallicRoughness['baseColorTexture'].texture;
      const input = document.querySelector('#variant');

      const createAndApplyTexture = async (channel, file) => {
        const texture = await modelViewerTexture.createTexture(file);
        if (channel.includes('base') || channel.includes('metallic')) {
          material.pbrMetallicRoughness[channel].setTexture(texture);
        } else {
          material[channel].setTexture(texture);
        }
      }

      input.addEventListener('change', () => {
        var d = input.value;
        if(d.includes('Default')){
          material.pbrMetallicRoughness['baseColorTexture'].setTexture(saveTexture);
        }else{
          createAndApplyTexture('baseColorTexture', d);
        }

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