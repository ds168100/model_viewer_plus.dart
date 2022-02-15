const modelViewerVariants = document.querySelector("model-viewer#model");
const select = document.querySelector('#variant');
//console.log(JSON.stringify(modelViewerVariants));
modelViewerVariants.addEventListener('load', () => {
    const names = modelViewerVariants.availableVariants;
    for (const name of names) {
        const option = document.createElement('option');
        option.value = name;
        option.textContent = name;
        select.appendChild(option);
    }
});

select.addEventListener('input', (event) => {
    modelViewerVariants.variantName = event.target.value === 'default' ? null : event.target.value;
});
