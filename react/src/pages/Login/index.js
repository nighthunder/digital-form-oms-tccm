import React, { useState } from 'react';
import { useHistory } from "react-router-dom";
import './styles.css';
import { TextField, Button, CircularProgress } from '@material-ui/core';
import api from '../../services/api';
import { AES, mode } from 'crypto-js';
//import logo from '../../../public/assets/logo-vodan.png';

import { connect } from 'react-redux';

const styles = {
  TextField: {
    margin: 24,
    marginTop: 0
  },
  Button: {
    margin: 24,
    marginBottom: 0
  }
};

function userLogin(userData) {
  return {
    type: 'TOGGLE_LOGIN',
    isLogged: true,
    user: userData
  }
}

function Login({ logged, dispatch }) {

  const [form, setForm] = useState({
    email: '',
    senha: '',
    error: false
  });

  const [error, setError] = useState('')

  const history = useHistory();

  const [loading, setLoading] = useState(false);

  async function handleLogin(e) {
    e.preventDefault();
    const encryptedPassword = AES.encrypt(form.senha, 10, { mode: mode.ECB }).toString();
    setLoading(true);
    try {
      const response = await api.post('/login',  {
        login: form.email,
        password: encryptedPassword
      });

      console.log(response.data[0]);
      if(response.data[0].userid) {
        localStorage.setItem('authToken', 'token');
        localStorage.setItem('username', response.data[0].firstname);
        dispatch(userLogin(response.data));
        if(response.data.length === 1) {
          history.replace("/prontuario", { hospitalName: response.data[0].hospitalName, hospitalId: response.data[0].hospitalunitid, hospitalIndex: 0 });
        } else {
          history.replace("/hospital");
        }
        
      }
    } catch(e) {
      console.log(e);
      if(e.message.slice(-3) === '403') {
        setError('Email ou senha inválidas');
        setLoading(false);
      }
    }

  }
  
  function handleChange(e) {
    const target = e.target;
    const value = target.value;
    const name = target.name;
    setError('');
    setForm({
        ...form,
        [name]: value,
    });
  }

  return (
    <div className="container login">
      <form noValidate autoComplete="off" onSubmit={handleLogin}>
        <img src="assets/logo-vodan.png" />
        <TextField style={styles.TextField} name="email" label="Email" type="email" onChange={handleChange} />
        <TextField style={styles.TextField} name="senha" label="Senha" type="password" onChange={handleChange} />
        <span className="error">{error}</span>
        <Button style={styles.Button} variant="contained" type="submit" color="primary" disabled={form.email === '' || form.senha === ''}>
          { !loading &&
            'Entrar'
          }
          { loading &&
            <CircularProgress color="white"/>
          }
        </Button>
      </form>
    </div>
  );
}
  
export default connect(state => ({ logged: state }))(Login);