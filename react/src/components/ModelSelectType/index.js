import React from 'react';
import './styles.css';
class ModelSelectType extends React.Component {

  constructor(props) {
    super(props);
    this.state = {value: ''};

    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(e) {
    console.log("value Selected!!", e.target.value);
    this.setState({ value: e.target.value });
  }

  render() {
    return (
      <div id="App">
        <div className="select-container">
          <select 
            value={this.state.value} 
            onChange={this.handleChange} 
            placeholder={this.props.placeHolder} 
            id={this.props.id} 
            className="select-container-options"
            required="required"
          >
            {this.props.options.map((option) => (
              <option value={option.value}>{option.label}</option>
            ))}
          </select>
        </div>
      </div>
    );
  }
}

export default ModelSelectType