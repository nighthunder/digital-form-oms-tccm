import React from 'react';
import './styles.css';
import { SingleSelect } from "react-select-material-ui";
// import Select from '@mui/material/Select';
import Select from 'react-select';

class ModelSelectType extends React.Component {
  // state = {
  //   selectedOption: null,
  // };
  // handleChange = (selectedOption) => {
  //   this.setState({ selectedOption }, () =>
  //     console.log(`Option selected:`, this.state.selectedOption)
  //   );
  // };
  // render() {
  //   const { selectedOption } = this.state;

  //   return (
  //     <Select
  //           id={this.props.id}
  //           placeholder={this.props.placeHolder} 
  //           options={this.props.options} 
  //           value={selectedOption}
  //           onChange={this.handleChange} 
  //       />
  //   );
  // }

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
          <select value={this.state.value} onChange={this.handleChange} placeholder={this.props.placeHolder} id={this.props.id}>
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