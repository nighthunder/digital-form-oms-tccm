import React from 'react';
import './styles.css';
import { TextField } from '@material-ui/core';

class NewInput extends React.Component {
    constructor(props) {
      super(props);
      this.state = {value: ''};
  
      this.handleChange = this.handleChange.bind(this);
    }
  
    handleChange(event) {
      this.setState({value: event.target.value});
    }
  
    render() {
      return (
        <TextField 
            fullWidth 
            id={this.props.id} 
            label={this.props.descriptionInput} 
            variant="outlined" 
            value={this.state.value}
            onChange={this.handleChange} 
        />
      );
    }
  }

export default NewInput