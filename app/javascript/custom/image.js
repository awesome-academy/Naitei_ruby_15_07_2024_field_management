document.addEventListener("turbo:load", function() {
  const imageInput = document.querySelector("input[type='file'][multiple]");
  const imagePreviewContainer = document.getElementById("image-preview-container");
  const imageStorageInput = document.getElementById("image-storage-input");

  let imageList = [];

  if (imageInput) {
    imageInput.addEventListener("change", function(event) {
      const files = event.target.files;

      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const reader = new FileReader();

        reader.onload = function(e) {
          const imgContainer = document.createElement("div");
          imgContainer.style.position = "relative";
          imgContainer.style.display = "inline-block";
          imgContainer.style.margin = "10px";

          const img = document.createElement("img");
          img.src = e.target.result;
          img.style.maxWidth = "400px";
          img.style.marginRight = "10px";

          const removeBtn = document.createElement("button");
          removeBtn.textContent = "X";
          removeBtn.style.position = "absolute";
          removeBtn.style.top = "0";
          removeBtn.style.right = "0";
          removeBtn.style.background = "red";
          removeBtn.style.color = "white";
          removeBtn.style.border = "none";
          removeBtn.style.cursor = "pointer";

          removeBtn.addEventListener("click", function() {
            const index = imageList.indexOf(e.target.result);
            if (index !== -1) {
              imageList.splice(index, 1);
              updateImageStorageInput();
            }
            imgContainer.remove();
          });

          imgContainer.appendChild(img);
          imgContainer.appendChild(removeBtn);
          imagePreviewContainer.appendChild(imgContainer);

          imageList.push(e.target.result);
          updateImageStorageInput();
        }

        reader.readAsDataURL(file);
      }
    });
  }

  function updateImageStorageInput() {
    imageStorageInput.value = JSON.stringify(imageList);
  }
});
