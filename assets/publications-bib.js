const copyButtonLabel = "Copy Code";

// run code when document is ready
document.addEventListener("DOMContentLoaded", () => {

    // use a class selector if available
    let blocks = document.querySelectorAll("pre");

    blocks.forEach((block) => {
        // only add button if browser supports Clipboard API
        if (navigator.clipboard) {
            let button = document.createElement("button");

            button.innerText = copyButtonLabel;
            block.appendChild(button);
            block.setAttribute("tabindex", 0);

            button.addEventListener("click", async () => {
                await copyCode(block, button);
            });
        }
    });

    async function copyCode(block, button) {
        let code = block.querySelector("code");
        let text = code.innerText;

        await navigator.clipboard.writeText(text);

        // visual feedback that task is completed
        button.innerText = "Code Copied";
        button.disabled = true;

        setTimeout(() => {
            button.innerText = copyButtonLabel;
            button.disabled = false;
        }, 700);
    }

});