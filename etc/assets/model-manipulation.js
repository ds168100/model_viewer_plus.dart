
const modelViewerTransform = document.querySelector("model-viewer#model");

let currentRoll = 0;
let currentPitch = 0;
let currentYaw = 0;

let currentScale = 1;

const updateOrientation = () => {
  modelViewerTransform.orientation = `${currentRoll}deg ${currentPitch}deg ${currentYaw}deg`;
};

const updateScale = () => {
  modelViewerTransform.scale = `${currentScale} ${currentScale} ${currentScale}`;
};

const increaseRoll = () => {
    currentRoll += 5;
    updateOrientation();
};

const decreaseRoll = () => {
    currentRoll -= 5;
    updateOrientation();
};

const increasePitch = () => {
    currentPitch += 5;
    updateOrientation();
};

const decreasePitch = () => {
    currentPitch -= 5;
    updateOrientation();
};

const increaseYaw = () => {
    currentYaw += 5;
    updateOrientation();
};

const decreaseYaw = () => {
    currentYaw -= 5;
    updateOrientation();
};

const increaseScale = () => {
    currentScale += 1;
    updateScale();
};

const decreaseScale = () => {
    currentScale -= 1;
    updateScale();
};
