import * as React from "react";

import reactLogo from "./../assets/img/react_logo.svg"
import "./../assets/scss/App.scss";

export default class App extends React.Component<{}> {
  public render() {
    return (
      <div className="app">
        <h1>Hello World!</h1>
        <p>Foo to the barz</p>
        <img src={reactLogo} height="480" />
      </div>
    );
  }
}