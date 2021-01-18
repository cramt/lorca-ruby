import * as React from "react";
import { render } from "react-dom";
import App from "./components/App";

document.addEventListener("DOMContentLoaded", () => {
    const rootEl = document.getElementById("root");

    render(<App />, rootEl);
})
