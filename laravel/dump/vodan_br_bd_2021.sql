-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 24, 2021 at 02:04 AM
-- Server version: 10.4.21-MariaDB
-- PHP Version: 7.3.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vodan_br_bd_2021`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateUserAdmin` (OUT `p_msg_retorno` VARCHAR(500))  sp:BEGIN

declare v_userid integer;

DECLARE EXIT HANDLER FOR SQLEXCEPTION, 1062 
BEGIN
	ROLLBACK;
	SELECT 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!' Message; 
END;
  

START TRANSACTION;

# criação do administrador do sistema
Insert into tb_user
(login, firstName, lastName, regionalCouncilcode, password, email, fonenumber)
values ('Admin', 'Administrador', 'Sistema', 'CRM/CRF', 'admin', 'adminsys@gmail.com', '5555-5555');

set v_userid = LAST_INSERT_ID();

If v_userid is null then
   ROLLBACK;
   leave sp;
end if;

## associando o usuario administrador para cada um dos hospitais cadastrados no sistema
Insert into tb_userrole (userid, grouproleid, hospitalunitid, creationDate)
select v_userid, 1, hospitalunitid, now() from tb_hospitalUnit;

set p_msg_retorno = 'Cadastro realizado com sucesso';

COMMIT;

 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllQuestionnaires` ()  select t1.questionnaireID, 	
	   t1.description,
       t1.version,
       t1.lastModification,
       t1.creationDate,
	   translate('pt-br',t2.description) as questionnaireStatus
from tb_questionnaire as t1, 
	 tb_questionnairestatus as t2
where t1.questionnaireStatusID = t2.questionnaireStatusID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getcrfForms` (IN `p_questionnaireID` INT)  BEGIN
#========================================================================================================================
#== Procedure criada para retornar os modulos associados a um Questionario de Avaliação (Pesquisa Clinica)
#== Criada em 25 jan 2021
#========================================================================================================================
  select t1.crfFormsId, translate('pt-br', t1.description) as description
  from tb_crfforms t1, tb_questionnaire t2
  where t1.questionnaireID = t2.questionnaireID and
        t2.questionnaireID = p_questionnaireID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getModulesMedicalRecord` (`p_MedicalRecord` VARCHAR(255), `p_hospitalUnitId` INTEGER)  BEGIN
#========================================================================================================================
#== Procedure criada para retornos os modulos existentes para um paciente no sistema
#== Alterada em 23 Fev de 2021
#== Tratar os novos prontuarios - nao possuem nenhum módulo lançado
#== 27 dez 2020
#== inserido tratamento para verificar se o numero do prontuario está cadastrado para o hospital
#== caso nao esteja procedure retorna msg informando o problema.
#========================================================================================================================

DECLARE v_msg_retorno varchar(500);
DECLARE v_participantId integer;

sp:Begin
	    set v_participantID = null;
        
        select participantID into v_participantId from tb_participant
               where medicalRecord = p_MedicalRecord;
 
		if v_participantId is null then
			set v_msg_retorno = 'Prontuario Médico não cadastrado para o Hospital. Verifique!';
            select v_msg_retorno as msgRetorno from DUAL;
            leave sp;
        end if;

		select t2.participantID, t2.medicalRecord, t1.formrecordid, t1.crfformsid, t3.description as Modulo, 
				( select t4.answer from tb_QuestionGroupFormRecord t4 where
						t4.formRecordId = t1.formRecordId and
						t4.crfFormsID = t1.crfFormsID and
						t4.questionid in (167,168,124) ) as dataRefer, #avaliando datas de cada formulário
						t1.dtRegistroForm as dtRegistroSystem,
						(select count(*) from tb_questiongroupform t5 where
										  t5.crfFormsID = t1.crfFormsID) as questionTot,
						(select count(*) from tb_questiongroupformRecord t6 where
										  t6.crfFormsID = t1.crfFormsID and
                                          t6.formRecordID = t1.formRecordID  ) as questionAnswerTot
		from 
			tb_participant t2
			left join tb_formrecord t1 on t1.participantid = t2.participantid and
									      t1.hospitalUnitID = p_hospitalUnitId
            left join  tb_crfforms T3 on t3.crfFormsID = t1.crfFormsID
		where 
			t2.medicalRecord = p_medicalRecord
		order by dataRefer, t1.crfformsID;
END; # fim do sp:

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getqst_rsp_modulo` (`p_crfformid` INTEGER)  BEGIN
#========================================================================================================================
#== Procedure criada para retornar todas as questoes de um modulo 
#== As questões podem estar associadas diretamente ao modulo ou a um agrupamento
#== Alterada em 16 dez 2020
#== Criada em 19 nov 2020
#========================================================================================================================

 select crfformsid as modId, questionid as qstId,
	      translate('pt-br', questionGroup) as dsc_qst_grp,
		 translate('pt-br', question) as dsc_qst,
	 		    questionType as qst_type,
	            (select  GROUP_CONCAT(translate('pt-br',tlv.description)) as listofvalue from tb_listofvalues tlv
                 where listtypeid = tb_Questionario.listtypeid
                 order by tlv.listOfValuesID) as rsp_pad,
	            (select  GROUP_CONCAT(convert(tlv1.listOfValuesID, char)) as listofvalueID from tb_listofvalues tlv1
                 where tlv1.listtypeid = tb_Questionario.listtypeid
                 order by tlv1.listOfValuesID) as rsp_padId,
                 cast(IdQuestaoSubordinada_A as UNSIGNED ) as idsub_qst,
	             translate('pt-br', questaosubordinada_a) as sub_qst
		from (
			select crfformsid, questionid, questionorder, 
				   formulario, 
				   (case when questiongroup is null then '' else questiongroup end) as questionGroup,
				   (case when commentquestiongroup is null then '' else commentquestiongroup end) as commentquestiongroup,
				   Question,
				   QuestionType, listTypeResposta, listTypeID, IdQuestaoSubordinada_A, QuestaoSubordinada_A, QuestaoReferente_A
			from (
			select t5.crfformsid, t1.questionid, t9.questionorder,
				   t5.description as formulario,
				   (select t2.description from tb_questiongroup t2 where t2.questiongroupid = t1.questiongroupid) as questionGroup,
				   (select t2.comment from tb_questiongroup t2 where t2.questiongroupid = t1.questiongroupid) as commentquestionGroup,
					t1.description as question,
				   (select t3.description as questionType from tb_questiontype t3 where t3.questiontypeid = t1.questiontypeid) as questionType,
				   (select t6.description from tb_listType t6 where t6.listtypeid = t1.listtypeid) as listTypeResposta,
				   t1.listtypeid,
                   (select t7.questionid from tb_questions t7 where t7.questionId = t1.subordinateTo) as IdQuestaoSubordinada_A,
				   (select description from tb_questions t7 where t7.questionId = t1.subordinateTo) as QuestaoSubordinada_A,
				   (select description from tb_questions t8 where t8.questionId = t1.isabout) as QuestaoReferente_A
			from tb_questions t1,  tb_crfForms t5, tb_questionGroupForm t9
			where t5.crfformsid = p_crfformid and
			t9.crfformsid = t5.crfformsid and t9.questionid = t1.questionid
			) as tabela_Formulario ) as tb_Questionario
			Order by crfformsid, questionorder;	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getqst_rsp_modulo_medicalRecord` (`p_formRecordId` INTEGER)  BEGIN
#========================================================================================================================
#== Procedure criada para retornar as respostas de um módulo já inserido no sistema
#== Atençao ao retorno das questões respondidas. Importante verificar se a resposta esta associada a uma list type ou não
#== Atenção as questões referentes a laboratório. Resultado pode conter o valor anormal medido ou o texto 'Não feito'
#== Criada em 07 dez 2020
#========================================================================================================================
DECLARE v_crfformsid integer;

# Capturando o modulo que será retornado
set v_crfformsid = 0;
    
select crfFormsID into v_crfformsid from tb_formrecord  
           where formRecordID = p_formRecordId;
           
select   tb_Qst.crfformsid as modId, tb_Qst.questionid as qstId,
				translate('pt-br', tb_Qst.questionGroup) as dsc_qst_grp,
				translate('pt-br', tb_Qst.question) as dsc_qst,
				tb_Qst.questionType as qst_type,
				tb_rspt.listOfvaluesid, translate('pt-br', tb_rspt.listofvalue) as rsp_listofvalue,
				tb_rspt.answer,
					   # (select  GROUP_CONCAT(translate('pt-br',tlv.description), ' | ') as listofvalue from tb_listofvalues tlv
					   #  where listtypeid = tb_Questionario.listtypeid ) as rsp_pad,
				cast(tb_Qst.IdQuestaoSubordinada_A as UNSIGNED ) as idsub_qst,
				translate('pt-br', tb_Qst.questaosubordinada_a) as sub_qst
				from (
					select crfformsid, questionid, questionorder, 
						   formulario, 
						   (case when questiongroup is null then '' else questiongroup end) as questionGroup,
#						   (case when commentquestiongroup is null then '' else commentquestiongroup end) as commentquestiongroup,
						   Question,
						   QuestionType, listTypeResposta, listTypeID, IdQuestaoSubordinada_A, QuestaoSubordinada_A, QuestaoReferente_A
					from (
					select t5.crfformsid, t1.questionid, t9.questionorder,
						   t5.description as formulario,
						   (select t2.description from tb_questiongroup t2 where t2.questiongroupid = t1.questiongroupid) as questionGroup,
						   t1.description as question,
						   (select t3.description as questionType from tb_questiontype t3 where t3.questiontypeid = t1.questiontypeid) as questionType,
						   (select t6.description from tb_listType t6 where t6.listtypeid = t1.listtypeid) as listTypeResposta,
						   t1.listtypeid,
						   (select t7.questionid from tb_questions t7 where t7.questionId = t1.subordinateTo) as IdQuestaoSubordinada_A,
						   (select description from tb_questions t7 where t7.questionId = t1.subordinateTo) as QuestaoSubordinada_A,
						   (select description from tb_questions t8 where t8.questionId = t1.isabout) as QuestaoReferente_A
					from tb_questions t1,  tb_crfForms t5, tb_questionGroupForm t9
					where t5.crfformsid = v_crfformsid and
					t9.crfformsid = t5.crfformsid and t9.questionid = t1.questionid
					) as tabela_Formulario ) as tb_Qst
                    left join
                    ( Select t1.formRecordId, t1.participantid, t1.hospitalunitid,
							 t1.crfformsid, t2.questiongroupformRecordId, t2.questionId,
							 t2.listOfvaluesid, (select description from tb_listofvalues t3 where t3.listofvaluesid = t2.listofvaluesid) as listofvalue,
							 t2.answer
						from tb_formrecord t1, tb_questiongroupformrecord t2
							  where t2.formRecordID = t1.formRecordID and
								    t1.crfformsid = v_crfformsid and
                                    t1.formrecordid = p_formrecordid ) as tb_Rspt
					on tb_rspt.questionId = tb_qst.questionid
					Order by tb_qst.crfformsid, tb_qst.questionorder;	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getQuestionnaire` (IN `p_questionnaireID` INT)  BEGIN
Select * from tb_questionnaire;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getuser` (`p_login` VARCHAR(255), `p_password` VARCHAR(255))  BEGIN
#========================================================================================================================
#== Procedure criada para validar um usuário no sistema
#== Se Login e password estiverem corretas retorna
#== UserId, FirstName, LastName, HospitalUnitId, HospitalUnitName, expirationDate,
#== situation, grouproleid, userrole
#== Atenção: Retornará todos os hospitais para os quais o usuário tenha um papel associado, podendo apresentar acesso expirado.
#== Alterada em 07 dez 2020
#========================================================================================================================
 		   select t1.userid, 
                 t1.firstname, 
                 t1.lastname, 
                 t3.hospitalunitid, 
                 t3.hospitalunitname as hospitalName, 
                 t2.expirationdate,
				case when (t3.hospitalunitid is not null) and (t2.expirationdate) is null then 'Ativo'
                     when (t3.hospitalunitid is null) and (t2.expirationdate) is null then 'Usuário Ativo, sem hospital associado.'
				else 'Acesso expirado. Contacte o Administrador.' end as situation,
				t4.grouproleid, 
                t4.description as userrole
				from tb_user t1 left join tb_userRole t2 on t2.userid = t1.userid
                left join tb_HospitalUnit t3 on  t3.hospitalunitid = t2.hospitalunitid
                left join tb_grouprole t4 on t4.grouproleid = t2.grouproleid
			where  t1.login = p_login and
				   t1.password = p_password;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `postgrouproleforuserhospital` (`p_adminid` INTEGER, `p_adminGroupRoleid` INTEGER, `p_adminHospitalUnitid` INTEGER, `p_userid` INTEGER, `p_groupRole` VARCHAR(255), OUT `p_msg_retorno` VARCHAR(500))  sp:BEGIN
#========================================================================================================================
#== Procedure criada para a inclusão/alteração de roles para usuários no sistema
#== Cria a associação de um usuário a um hospital exercendo um papel
#== Atenção o usuario será associado ao hospital ao qual o administrador esta associado
#== Se esse papel já existe, restabelece ou cancela o acesso por meio da data de expiração
#== Criada em 07 dez 2020
#========================================================================================================================

DECLARE v_Exist integer;
DECLARE v_grouproleId integer;
DECLARE v_hospitalUnitName varchar(500);
DECLARE v_expiration timestamp;
DECLARE v_alteracao text;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, 1062 
    BEGIN
		ROLLBACK;
        SELECT 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!' Message; 
    END;
    
    set p_groupRole = rtrim(ltrim(p_groupRole));
    set v_hospitalUnitName = '';
 	
    # verificando preenchimento dos campos considerados obrigatórios
	if ( p_userid is null or p_userid = 0 or p_groupRole = '' ) then
	    set p_msg_retorno = 'Campos obrigatórios devem ser preenchidos. Verifique.';
        leave sp;
	end if;
	
    # identificando o hospital para associação do usuário
    select hospitalUnitName into v_hospitalUnitName from tb_HospitalUnit
           where HospitalUnitId = p_adminHospitalUnitid ;
	
    if v_hospitalUnitName is null then
	    set p_msg_retorno = 'Verifique o Hospital.';
        leave sp;
	end if;
    
    # Identificando o papel do usuário para o hospital
    select groupRoleID into v_grouproleId from tb_grouprole 
           where description = p_groupRole;
    
    if v_groupRoleId is null then
	    set p_msg_retorno = 'Verifique o papel selecionado. ';
        leave sp;
	end if;

   # verificando se o usuário já existe no sistema associado ao hospital/papel
   select 1 into v_exist from tb_userrole where 
				userid = p_userid and grouproleid = v_grouproleid and hospitalunitid = p_adminHospitalUnitid;
   
   START TRANSACTION;
	# se usuário existir 
    if v_Exist = 1 then
			# verificar data de expiração 	
			set v_expiration = null;
			
			select expirationDate into v_expiration from tb_userrole where 
				userid = p_userid and grouproleid = v_grouproleid and hospitalunitid = p_adminHospitalunitid;

			if v_expiration is null then
                # Suspende acesso do usuário ao hospital no referido papel 
				Update tb_userrole
				set expirationDate = now()
				where userid = p_userid and grouproleid = v_grouproleid and hospitalunitid = p_adminHospitalunitid;
                
                set v_alteracao = CONCAT( 'Suspenso acesso do usuário', CONVERT(p_userid, char), ' ao hospital ', v_hospitalUnitName);
			else 
				# libera usuário para acesso ao hospital no papel 
					Update tb_userrole
					set expirationDate = null
					where userid = p_userid and grouproleid = v_grouproleid and hospitalunitid = p_adminHospitalunitid;
                    
                    set v_alteracao = CONCAT( 'Retorno de acesso do usuário', CONVERT(p_userid, char), ' ao hospital ', v_hospitalUnitName);
			end if;
            
			set p_msg_retorno =  'Procedimento realizado com sucesso.';
	else 
		# Inserindo o registro do papel associado a um hospital             
		INSERT INTO tb_UserRole (
					userId, grouproleId, hospitalUnitId, creationDate )
				VALUES ( p_userid, v_grouproleid, p_adminHospitalUnitid, now() );

	    set v_alteracao = CONCAT( 'Concessão de acesso do usuário', CONVERT(p_userid, char), ' ao hospital ', v_hospitalUnitName);
		
        set p_msg_retorno = CONCAT ('Usuário registrado com sucesso para o hospital: ',  v_hospitalUnitName);
        
	end if;
    
    # registrando a informação de notificação de Ajuste de papel/hospital 
    INSERT INTO tb_notificationrecord (
			userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
            values (p_adminid, p_admingrouproleid, p_adminhospitalunitid, 'tb_userrole', 0, now(), 'A', v_alteracao);

    
	COMMIT;
		
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `postMedicalRecord` (IN `p_userid` INT, IN `p_groupRoleid` INT, IN `p_hospitalUnitid` INT, IN `p_questionnaireId` INT, IN `p_medicalRecord` VARCHAR(255))  BEGIN
#========================================================================================================================
#== Procedure criada para o registro de um participant associado a um hospital para futuro lançamento dos modulos do formulario
#== Cria o registro na tb_participant e na tb_AssessmentQuestionnaire
#== retorna um registro contendo o participantId e a msg de retorno
#== Alterada em 22 dez 2020
#== Criada em 21 dez 2020
#========================================================================================================================

DECLARE v_Exist integer;
DECLARE p_participantId integer;
DECLARE p_msg_retorno varchar(500);

sp:BEGIN 

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, 1062 
    BEGIN
		ROLLBACK;
        SELECT 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!' Message; 
    END;
    
	set p_medicalrecord = rtrim(ltrim(p_medicalRecord));

	if (p_medicalRecord is null) or ( p_medicalRecord = '')  then
 	    set p_msg_retorno = 'Informe o numero do prontuário eletronico para cadastro. ';
        leave sp;   
    end if;
    
    set p_participantId = null;
                         
	# verificando se já existe registro criado para o paciente no hospital para registro desse questionario
    Select t1.participantID into p_participantId from tb_assessmentquestionnaire t1, tb_participant t2
		where t1.participantID = t2.participantid and
			  hospitalUnitID = p_hospitalunitid and
              questionnaireID = p_questionnaireid and
              t2.medicalRecord = p_medicalRecord;
                         
 	if ( p_participantId is not null ) then
	    set p_msg_retorno = 'Prontuário já registrado para o Hospital.';
        leave sp;
	end if;
	
   START TRANSACTION;
	# Inserindo o registro do participante      
	INSERT INTO tb_participant (
			    medicalRecord)
                values (p_medicalRecord);
	set p_participantid = LAST_INSERT_ID();
    
	if p_participantid is NULL then
       ROLLBACK;
	    set p_msg_retorno = 'Erro no registro do Prontuario Medico. Verifique!';
        leave sp;
	end if;
    
    INSERT INTO tb_assessmentquestionnaire (
				participantID, hospitalUnitId, questionnaireId )
		    VALUES ( p_participantid, p_hospitalUnitid, p_questionnaireId );


    # registrando a informação de notificação para a inclusao do modulo 
    INSERT INTO tb_notificationrecord (
			userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
            values (p_userid, p_grouproleid, p_hospitalunitid, 'tb_participant', p_participantid, now(), 'I', CONCAT('Inclusão de paciente: ', p_medicalRecord));

    # registrando a informação de notificação para a inclusao da questão referente a data do modulo
    INSERT INTO tb_notificationrecord (
			userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
            values (p_userid, p_grouproleid, p_hospitalunitid, 'tb_assessmentquestionnaire', 0, now(), 'I', CONCAT('Inclusão do registro referente ao paciente: ', CONVERT(p_participantId, char), ' para o hospital: ', CONVERT(p_hospitalunitid, char)));
    
	COMMIT;

    set p_msg_retorno = 'Registro do Prontuario Medico com Sucesso';

END sp;	

 ## select inserido para tratar limitaçao do retorno de procedures no Laravel	
 select p_msg_retorno as msgRetorno from DUAL;
	
  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `postqstmoduloMedicalRecord` (`p_userid` INTEGER, `p_groupRoleid` INTEGER, `p_hospitalUnitid` INTEGER, `p_participantid` INTEGER, `p_questionnaireId` INTEGER, `p_crfFormId` INTEGER, `p_stringquestions` TEXT, OUT `p_formRecordId` INTEGER, OUT `p_msg_retorno` VARCHAR(500))  BEGIN
#========================================================================================================================
#== Procedure criada para incluir um modulo e registrar suas questoes e respostas de um módulo de um formulario no sistema para um participante
#== Criada em 21 dez 2020
#== Alterada em 24 jan 2021 - tratamento do idioma respostas padronizadas
#========================================================================================================================

DECLARE v_Exist integer;
DECLARE v_question varchar(50);
DECLARE v_answer varchar(500);
DECLARE v_questionid integer;
DECLARE v_listOfValuesid integer;
DECLARE v_listtypeid integer;
DECLARE v_questionGroupFormid integer;
DECLARE v_lista text;
DECLARE v_apoio varchar(500);
DECLARE v_resposta varchar(500);
DECLARE v_listofvaluesid_ant integer;
DECLARE v_answer_ant varchar(500);
DECLARE v_operacao varchar(01);
 

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, 1062 
    BEGIN
		ROLLBACK;
        SELECT 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!' Message; 
    END;
    
sp:BEGIN		
   START TRANSACTION;
   	# Inserindo o registro do form/modulo para o paciente             
	INSERT INTO tb_FormRecord (
				participantID, hospitalUnitId, questionnaireId, crfFormsID, dtRegistroForm )
		    VALUES ( p_participantid, p_hospitalUnitid, p_questionnaireId, p_crfformid, now() );

	set p_formRecordid = LAST_INSERT_ID();
    
    if p_formRecordid is NULL then
       ROLLBACK;
	    set p_msg_retorno = 'Erro na inclusão do módulo. Verifique!';
        leave sp;
	end if;
    
	# registrando a informação de notificação para a inclusao do modulo 
    INSERT INTO tb_notificationrecord (
			userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
            values (p_userid, p_grouproleid, p_hospitalunitid, 'tb_formRecord', p_formrecordid, now(), 'I', CONCAT('Inclusão de Modulo para paciente: ', CONVERT(p_participantId, char)));

	# Inserindo/Alterando as questoes registro do form e a questão associada a data    
    
    set v_lista = concat(p_stringquestions, ',') ;
    
    while length(v_lista) > 1 DO
		set v_apoio = substring(v_lista, 1, position(',' in v_lista));
		set v_question = substring(v_apoio, 1, position(':' in v_apoio) - 1);
		set v_answer     = substring(v_apoio, position(':' in v_apoio) + 1, position(',' in v_apoio) - 1);
        set v_answer     = REPLACE(v_answer, ',', '');
		set v_questionid = CONVERT(v_question, SIGNED);
	
        # verificando se a questão exige um tipo de resposta padronizada
        set v_listtypeid = null;
        set v_listofvaluesid = null;
        Select listtypeid into v_listtypeid from tb_questions
							where questionid = v_questionid;

		#select v_question, v_listtypeid, v_answer; 
		if (v_listtypeid is not NULL) then
               SELECT listofvaluesid into v_listOfValuesid 
                    from tb_listtype t1, tb_listofvalues t2
                    where t1.listTypeID = v_listtypeid and
						  t2.listTypeID = t1.listTypeID and
                          translate('pt-br', rtrim(ltrim(t2.description))) = rtrim(ltrim(v_answer)); 
                          
			   if v_listOfvaluesid is not null then
			         set v_resposta = concat('Resposta da ', v_question, ':', v_answer, ' - ', convert (v_listtypeid, char), ':', convert(v_listofvaluesid, char));
					 set v_answer = '';
			   else # não foi localizada resposta para a questão - nao será inserida
                     set v_resposta = '';
                     set v_answer = '';
			   end if;
	    else
			   set v_resposta = concat('Resposta da ', v_question, ':', v_answer);
               set v_listofvaluesid = null;
        end if;
 
		# select v_resposta, v_question, v_answer;

        if v_resposta <> '' then
        
				# verificar se a questão já havia sido respondido e o valor foi alterado
                select listofvaluesid, answer into v_listofvaluesid_ant, v_answer_ant
					    from tb_questiongroupformrecord
                        where formRecordID = p_formRecordid and questionid = v_question;
				
                # se questão ainda nao foi respondida
                if v_listofvaluesid_ant is null and v_answer_ant is null then
                        set v_operacao = 'I';
                        set v_resposta = CONCAT('Inclusão de ', v_resposta);
                        
						INSERT INTO tb_questiongroupformrecord (
							formRecordID, crfFormsID, questionid, listofvaluesid, answer)
							values (p_formRecordId, p_crfFormId, v_questionid, v_listofvaluesid, v_answer);
				
						set v_questionGroupFormid = LAST_INSERT_ID();
    
						if v_questionGroupFormid is NULL then
							ROLLBACK;
							set p_msg_retorno = 'Erro na inclusão do registro. Verifique!';
							leave sp;
						end if;
				else
                        set v_operacao = 'A';
                        set v_resposta = CONCAT('Exclusão da Resposta: ', convert(v_listofvaluesid_ant, char), ' - ', v_answer_ant, ' para Inclusão de ', v_resposta);

						select questionGroupFormRecordID into v_questionGroupFormid 
                            from tb_questiongroupformrecord
                        	where formRecordID = p_formrecordid and questionid = v_questionid;     

						Update tb_questiongroupformrecord 
                            set listofvaluesid = v_listofvaluesid,
                                answer = v_answer
							where questionGroupFormRecordID = v_questionGroupFormid;
                        
                
                end if;
				# registrando a informação de notificação para a inclusao/Alteração da questão referente a data do modulo
				INSERT INTO tb_notificationrecord (
						userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
						values (p_userid, p_grouproleid, p_hospitalunitid, 'tb_questiongroupformrecord', v_questionGroupFormid, now(), v_operacao, v_resposta);
 
	    end if;
        
  #      SELECT v_lista, length(v_lista), position(',' in v_lista);
        if position(',' in v_lista) < length(v_lista) then
	  	   set v_lista = substring(v_lista,  position(',' in v_lista) + 1, length(v_lista));
		else 
           set v_lista = '';
		end if;
	
	End While;
	    
	COMMIT;
END;

	select p_formRecordid, p_msg_retorno from DUAL;
		
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `postQuestionnaire` (IN `p_userID` INT, IN `p_groupRoleID` INT, IN `p_hospitalUnitID` INT, IN `p_questionnaireDescription` VARCHAR(255), IN `p_questionnaireVersion` VARCHAR(255), IN `p_questionnaireStatusID` INT, IN `p_questionnaireLastModification` TIMESTAMP, IN `p_questionnaireCreationDate` TIMESTAMP)  BEGIN
#========================================================================================================================
#== Procedure criada para o registro de um participant associado a um hospital para futuro lançamento dos modulos do formulario
#== Cria o registro na tb_participant e na tb_AssessmentQuestionnaire
#== retorna um registro contendo o participantId e a msg de retorno
#== Alterada em 22 dez 2020
#== Criada em 21 dez 2020
#========================================================================================================================

DECLARE p_userID integer;
DECLARE p_msg_retorno varchar(500);

sp:BEGIN 

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, 1062 
    BEGIN
		ROLLBACK;
        SELECT 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!' Message; 
    END;
    
	set p_questionnaireDescription = rtrim(ltrim(p_questionnaireDescription));

	if (p_questionnaireDescription is null) or ( p_questionnaireDescription = '')  then
 	    set p_msg_retorno = 'Informe uma descrição para a pesquisa. ';
        leave sp;   
    end if;

	
   START TRANSACTION;
	# Inserindo nova pesquisa       
    
    INSERT INTO tb_questionnaire (
			questionnaireID, description, questionnaireStatusID, isBasedOn, createdBy, version, 
    		lastModification, creationDate )
            values (DEFAULT, p_questionnaireDescription, p_questionnaireStatusID, NULL, NULL, p_questionnaireVersion, p_questionnaireLastModification, p_questionnaireCreationDate);


    # registrando a informação de notificação para a inclusao do modulo 
    INSERT INTO tb_notificationrecord (
			userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
            values (p_userid, p_grouproleid, p_hospitalunitid, 'tb_questionnaire', 1, now(), 'I', CONCAT('Criação de pesquisa: ', p_questionnaireDescription));
    
	COMMIT;

    set p_msg_retorno = 'Questionário criado com sucesso';

END sp;	

 ## select inserido para tratar limitaçao do retorno de procedures no Laravel	
select p_msg_retorno as msgRetorno from DUAL;
  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `postuser` (`p_adminid` INTEGER, `p_adminGroupRoleid` INTEGER, `p_adminHospitalUnitid` INTEGER, `p_login` VARCHAR(255), `p_firstname` VARCHAR(100), `p_lastname` VARCHAR(100), `p_regionalcouncilcode` VARCHAR(255), `p_password` VARCHAR(255), `p_email` VARCHAR(255), `p_fonenumber` VARCHAR(255), `p_groupRole` VARCHAR(255), OUT `p_userid` INTEGER, OUT `p_msg_retorno` VARCHAR(500))  sp:BEGIN
#========================================================================================================================
#== Procedure criada para a inclusão de usuários no sistema
#== Durante a inclusão realiza a associação do usuário a um Hospital, definindo o papel que ele exercerá
#== Atenção o usuario será associado ao hospital do administrador
#== Alterada em 09 dez 2020
#========================================================================================================================

DECLARE v_Exist integer;
DECLARE v_grouproleId integer;
DECLARE v_hospitalUnitName varchar(500);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, 1062 
    BEGIN
		ROLLBACK;
        SELECT 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!' Message; 
    END;
    
    set p_login = rtrim(ltrim(p_login));
    set p_firstName = rtrim(ltrim(p_firstName));
    set p_email = rtrim(ltrim(p_email));
    set p_fonenumber = rtrim(ltrim(p_fonenumber));
    set p_groupRole = rtrim(ltrim(p_groupRole));
    
    # verificando preenchimento dos campos considerados obrigatórios
	if (p_login = '' or p_firstName = '' or p_lastName = '' or p_email = '' or p_fonenumber = '' or p_groupRole = '' ) then
	    set p_msg_retorno = 'Campos obrigatórios devem ser preenchidos. Verifique.';
        leave sp;
	end if;
	
    # identificando o hospital para associação do usuário
    select hospitalUnitName into v_hospitalUnitName from tb_HospitalUnit
           where HospitalUnitid = p_adminHospitalUnitid;
	
    if v_hospitalUnitName is null then
	    set p_msg_retorno = 'Hospital não identificado no cadastro. Verifique.';
        leave sp;
	end if;
    
    # Identificando o papel do usuário para o hospital
    select groupRoleID into v_grouproleId from tb_grouprole 
           where description = rtrim(ltrim(p_groupRole));
    
    if v_groupRoleId is null then
	    set p_msg_retorno = 'Selecione um papel a ser exercido junto ao Hospital. ';
        leave sp;
	end if;
    
    # verificando se o usuário já existe no sistema
	select 1 into v_Exist from tb_user where login = p_login;
	
	if v_Exist = 1 then
	   set p_msg_retorno =  'Login já existe. Verifique.';
       leave sp;
	end if;
	
	select 1 into v_Exist from tb_user where email = p_email;
	if v_Exist = 1 then
	   set p_msg_retorno =  'e-mail já cadastrado no sistema. Verifique.';
       leave sp;
	end if;
    
    START TRANSACTION;
	
    # Inserindo o registro do usuário
	INSERT INTO tb_user(
		 login, firstname, lastname, regionalcouncilcode, password, email, fonenumber)
	VALUES ( p_login, p_firstName, p_lastName, p_regionalCouncilCode, p_Password, 
			 p_email, p_fonenumber);
             
    set p_userid = LAST_INSERT_ID();
    
    if p_userid is null then
       ROLLBACK;
	   set p_msg_retorno =  'Problemas na inclusão de informações. Verifique.';
       leave sp;
	end if;

    # Inserindo o registro do papel associado a um hospital             
	INSERT INTO tb_UserRole (
		  userId, grouproleId, hospitalUnitId, creationDate )
	VALUES ( p_userid, v_grouproleid, p_adminHospitalUnitId, now() );

	set p_msg_retorno = CONCAT ('Usuário registrado com sucesso para o hospital: ' , v_hospitalUnitName);
    
	# registrando a informação de notificação de inclusão do usuario 
    INSERT INTO tb_notificationrecord (
			userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
            values (p_adminid, p_admingrouproleid, p_adminhospitalunitid, 'tb_user', p_userid, now(), 'I', CONCAT('Inclusão de dados do Usuario: ', p_login));

 
    
    COMMIT;
	
		
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `putMedicalRecord` (IN `p_userid` INT, IN `p_groupRoleid` INT, IN `p_hospitalUnitid` INT, IN `p_questionnaireId` INT, IN `p_participantId` INT, IN `p_medicalRecordNew` VARCHAR(255), OUT `p_msg_retorno` VARCHAR(500))  BEGIN
#========================================================================================================================
#== Procedure criada para o atualizar o registro de um participant associado a um hospital para futuro lançamento dos modulos do formulario
#== Altera o numero do Prontuario na tb_participant
#== Alterada em 21 dez 2020
#========================================================================================================================

DECLARE v_MedicalRecordExist varchar(255);
DECLARE v_alteracao varchar(700);
 
sp:BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, 1062 
    BEGIN
		ROLLBACK;
        SELECT 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!' Message; 
    END;
    
	set p_medicalrecordNew = rtrim(ltrim(p_medicalRecordNew));

	if (p_medicalrecordNew is null) or ( p_medicalrecordNew = '')  then
 	    set p_msg_retorno = 'Informe o numero do prontuário eletronico para a atualização. ';
        leave sp;   
    end if;
                         
	# Confirmando o registro criado para o paciente no hospital para registro desse questionario
    Select t2.medicalRecord into v_MedicalRecordExist from tb_assessmentquestionnaire t1, tb_participant t2
		where t1.participantID = t2.participantid and
			  t1.hospitalUnitID = p_hospitalunitid and
              t1.questionnaireID = p_questionnaireid and
              t2.participantID = p_participantId;
                         
 	if ( v_MedicalRecordExist is null or v_MedicalRecordExist = '' ) then
	    set p_msg_retorno = 'Verifique o Participante.';
        leave sp;
	end if;
    
    if v_medicalRecordExist = p_medicalRecordNew then
	    set p_msg_retorno = 'Não há alteração no Número do Prontuario.';
        leave sp;    
    end if;
    
    set v_alteracao = CONCAT( '- Prontuario de: ', v_MedicalRecordExist, ' para ', p_medicalRecordNew);
	
   START TRANSACTION;
	# Inserindo o registro do participante      
	UPDATE  tb_participant
           SET  medicalRecord = p_medicalRecordNew
    where participantId = p_participantId;
    
	
 
    # registrando a informação de notificação para a Alteração do Prontuario Medico 
    INSERT INTO tb_notificationrecord (
			userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
            values (p_userid, p_grouproleid, p_hospitalunitid, 'tb_participant', p_participantid, now(), 'A', CONCAT('Alteração ' ,  v_alteracao));

    if  LAST_INSERT_ID() is NULL then
         ROLLBACK;
	     set p_msg_retorno = 'Erro na notificação da atualização do Prontuario Medico. Verifique!';
         leave sp;
	end if;
    
    set p_msg_retorno = 'Alteração realizada com sucesso.';

    COMMIT;
END sp;

## select inserido para tratar limitaçao do retorno de procedures no Laravel
Select p_participantid as participantId, p_msg_retorno as msgRetorno FROM DUAL;
		
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `putmoduloMedicalRecord` (`p_userid` INTEGER, `p_groupRoleid` INTEGER, `p_hospitalUnitid` INTEGER, `p_participantid` INTEGER, `p_questionnaireId` INTEGER, `p_crfFormId` INTEGER, `p_dataEvento` DATE, OUT `p_formRecordId` INTEGER, OUT `p_msg_retorno` VARCHAR(500))  BEGIN
#========================================================================================================================
#== Procedure criada para a inclusão de um módulo de um formulario no sistema para um participante
#== Cria o registro base do formulario e notifica o responsavel por essa inclusão
#== Alterada em 08 dez 2020
#========================================================================================================================

DECLARE v_Exist integer;
DECLARE v_questionid integer;
DECLARE v_questionGroupFormid integer;
 

sp:BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, 1062 
    BEGIN
		ROLLBACK;
        SELECT 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!' Message; 
    END;
    
	if p_dataEvento is null then
 	    set p_msg_retorno = 'Informar a data associada ao evento. Verifique.';
        leave sp;   
    end if;
    
    set v_questionid = case p_crfformid when  1 then 167  # data de admissão
										when  2 then 168  # data de acompanhamento
										else 124    #data do desfecho
					   end;
                     
	# verificando se já existe registro criado para a data informada
    Select 1 into v_Exist from tb_formrecord t1
		where participantID = p_participantid and
			  hospitalUnitID = p_hospitalunitid and
              crfFormsID = p_crfformid and
              exists (select 1 from tb_QuestionGroupFormRecord t2 
                   where t1.formrecordid = t2.formrecordid and
                         t2.questionid = v_questionid and
                         CONVERT(t2.answer, date) = p_dataevento);
                         
    # verificando preenchimento dos campos considerados obrigatórios
	if ( v_Exist = 1 ) then
	    set p_msg_retorno = 'Já existe módulo criado para esta data. Verifique.';
        leave sp;
	end if;
	
   START TRANSACTION;
	# Inserindo o registro do form e a questão associada a data             
	INSERT INTO tb_FormRecord (
				participantID, hospitalUnitId, questionnaireId, crfFormsID, dtRegistroForm )
		    VALUES ( p_participantid, p_hospitalUnitid, p_questionnaireId, p_crfformid, now() );

	set p_formRecordid = LAST_INSERT_ID();
    
    if p_formRecordid is NULL then
       ROLLBACK;
	    set p_msg_retorno = 'Erro na inclusão do registro. Verifique!';
        leave sp;
	end if;
    
    INSERT INTO tb_questiongroupformrecord (
             formRecordID, crfFormsID, questionid, answer)
             values (p_formRecordId, p_crfFormId, v_questionid, CONVERT(p_dataEvento, CHAR));
             
	set v_questionGroupFormid = LAST_INSERT_ID();
    
	if v_questionGroupFormid is NULL then
       ROLLBACK;
	    set p_msg_retorno = 'Erro na inclusão do registro. Verifique!';
        leave sp;
	end if;

    # registrando a informação de notificação para a inclusao do modulo 
    INSERT INTO tb_notificationrecord (
			userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
            values (p_userid, p_grouproleid, p_hospitalunitid, 'tb_formRecord', p_formrecordid, now(), 'I', CONCAT('Inclusão de Modulo para paciente: ', CONVERT(p_participantId, char)));

    # registrando a informação de notificação para a inclusao da questão referente a data do modulo
    INSERT INTO tb_notificationrecord (
			userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
            values (p_userid, p_grouproleid, p_hospitalunitid, 'tb_questiongroupformrecord', v_questionGroupFormid, now(), 'I', CONCAT('Inclusão da questão referente a data do Modulo para paciente: ', CONVERT(p_participantId, char)));
    
	COMMIT;
    
    set p_msg_retorno = 'Inclusão com sucesso.';

END sp;
 ## select inserido para tratar limitaçao do retorno de procedures no Laravel
select p_formrecordid as formRecordId, p_msg_retorno as msgRetorno from DUAL;
		
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `putqstmoduloMedicalRecord` (`p_userid` INTEGER, `p_groupRoleid` INTEGER, `p_hospitalUnitid` INTEGER, `p_participantid` INTEGER, `p_questionnaireId` INTEGER, `p_crfFormId` INTEGER, `p_formRecordId` INTEGER, `p_stringquestions` TEXT, OUT `p_msg_retorno` VARCHAR(500))  BEGIN
#========================================================================================================================
#== Procedure criada para o registro das questoes e respostas de um módulo de um formulario no sistema para um participante
#== Criada em 21 dez 2020
#== Alterada em 24 jan 2021 - ajuste da traduçao das respostas padronizadas
#========================================================================================================================

DECLARE v_Exist integer;
DECLARE v_question varchar(50);
DECLARE v_answer varchar(500);
DECLARE v_questionid integer;
DECLARE v_listOfValuesid integer;
DECLARE v_listtypeid integer;
DECLARE v_questionGroupFormid integer;
DECLARE v_lista text;
DECLARE v_apoio varchar(500);
DECLARE v_resposta varchar(500);
DECLARE v_listofvaluesid_ant integer;
DECLARE v_answer_ant varchar(500);
DECLARE v_operacao varchar(01);
 

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, 1062 
    BEGIN
		ROLLBACK;
        SELECT 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!' Message; 
    END;
    
sp:BEGIN		
   START TRANSACTION;
	# Inserindo/Alterando as questoes registro do form e a questão associada a data    
    
    set v_lista = concat(p_stringquestions, ',') ;
    
    while length(v_lista) > 1 DO
		set v_apoio = substring(v_lista, 1, position(',' in v_lista));
		set v_question = substring(v_apoio, 1, position(':' in v_apoio) - 1);
		set v_answer     = substring(v_apoio, position(':' in v_apoio) + 1, position(',' in v_apoio) - 1);
        set v_answer     = REPLACE(v_answer, ',', '');
		set v_questionid = CONVERT(v_question, SIGNED);
	
        # verificando se a questão exige um tipo de resposta padronizada
        set v_listtypeid = null;
        set v_listofvaluesid = null;
        Select listtypeid into v_listtypeid from tb_questions
							where questionid = v_questionid;

		#select v_question, v_listtypeid, v_answer; 
		if (v_listtypeid is not NULL) then
               SELECT listofvaluesid into v_listOfValuesid 
                    from tb_listtype t1, tb_listofvalues t2
                    where t1.listTypeID = v_listtypeid and
						  t2.listTypeID = t1.listTypeID and
                          translate('pt-br', rtrim(ltrim(t2.description))) = rtrim(ltrim(v_answer)); 
                          
			   if v_listOfvaluesid is not null then
			         set v_resposta = concat('Resposta da ', v_question, ':', v_answer, ' - ', convert (v_listtypeid, char), ':', convert(v_listofvaluesid, char));
					 set v_answer = '';
			   else # não foi localizada resposta para a questão - nao será inserida
                     set v_resposta = '';
                     set v_answer = '';
			   end if;
	    else
			   set v_resposta = concat('Resposta da ', v_question, ':', v_answer);
               set v_listofvaluesid = null;
        end if;

        if v_resposta <> '' then
        
                set v_listofvaluesid_ant = null;
                set v_answer_ant = null;
        
				# verificar se a questão já havia sido respondido e o valor foi alterado
                select listofvaluesid, answer into v_listofvaluesid_ant, v_answer_ant
					    from tb_questiongroupformrecord
                        where formRecordID = p_formRecordid and questionid = v_question;
                if v_answer_ant = '' then
                   set v_answer_ant = null;
				end if;
                
                # se questão ainda nao foi respondida
                if v_listofvaluesid_ant is null and v_answer_ant is null then
                        set v_operacao = 'I';
                        set v_resposta = CONCAT('Inclusão de ', v_resposta);
                        
						INSERT INTO tb_questiongroupformrecord (
							formRecordID, crfFormsID, questionid, listofvaluesid, answer)
							values (p_formRecordId, p_crfFormId, v_questionid, v_listofvaluesid, v_answer);
				
						set v_questionGroupFormid = LAST_INSERT_ID();
    
						if v_questionGroupFormid is NULL then
							ROLLBACK;
							set p_msg_retorno = 'Erro na inclusão do registro. Verifique!';
							leave sp;
						end if;
				else
						# select v_listofvaluesid_ant, v_answer_ant, v_listofvaluesid, v_answer;
                        if (v_listofvaluesid_ant is not null and v_listofvaluesid_ant = v_listofvaluesid) or
                           (v_answer_ant is not null and v_answer_ant = v_answer) then
                           set v_operacao = '';
                           set v_resposta = '';
						else 
							#select 'A', v_listofvaluesid_ant, v_answer_ant, v_listofvaluesid, v_answer;
							set v_operacao = 'A';
                            if v_listofvaluesid_ant is not null then
							   set v_resposta = CONCAT('Exclusão da Resposta: ', convert(v_listofvaluesid_ant, char), ' para Inclusão de ', v_resposta);
							end if;
                            
                            if v_answer_ant is not null then
							   set v_resposta = CONCAT('Exclusão da Resposta: ', v_answer_ant, ' para Inclusão de ', v_resposta);
							end if;
                            
							select questionGroupFormRecordID into v_questionGroupFormid 
								from tb_questiongroupformrecord
								where formRecordID = p_formrecordid and questionid = v_questionid;     

							Update tb_questiongroupformrecord 
								set listofvaluesid = v_listofvaluesid,
									answer = v_answer
								where questionGroupFormRecordID = v_questionGroupFormid;
						end if;	
                
                end if;
                
                if v_operacao <> '' then
					# registrando a informação de notificação para a inclusao/Alteração da questão referente a data do modulo
					INSERT INTO tb_notificationrecord (
							userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
							values (p_userid, p_grouproleid, p_hospitalunitid, 'tb_questiongroupformrecord', v_questionGroupFormid, now(), v_operacao, v_resposta);
			    end if;
		end if;
        
        if position(',' in v_lista) < length(v_lista) then
	  	   set v_lista = substring(v_lista,  position(',' in v_lista) + 1, length(v_lista));
		else 
           set v_lista = '';
		end if;
          
	End While;
    
	COMMIT;
END;

   select p_msg_retorno from DUAL;
		
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `putuser` (`p_adminid` INTEGER, `p_adminGroupRoleid` INTEGER, `p_adminHospitalUnitid` INTEGER, `p_userid` INTEGER, `p_login` VARCHAR(255), `p_firstname` VARCHAR(100), `p_lastname` VARCHAR(100), `p_regionalcouncilcode` VARCHAR(255), `p_password` VARCHAR(255), `p_email` VARCHAR(255), `p_fonenumber` VARCHAR(255), OUT `p_msg_retorno` VARCHAR(500))  sp:BEGIN
#========================================================================================================================
#== Procedure criada para realizar a alteração de dados do usuário no sistema
#== Alterada em 09 dez 2020
#========================================================================================================================

DECLARE v_Exist integer;
DECLARE v_dadosOriginais text;
DECLARE v_dadosAlterados text;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, 1062 
    BEGIN
		ROLLBACK;
        SELECT 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!' Message; 
    END;
    
    set p_login = rtrim(ltrim(p_login));
    set p_firstName = rtrim(ltrim(p_firstName));
    set p_email = rtrim(ltrim(p_email));
    set p_fonenumber = rtrim(ltrim(p_fonenumber));
    
    # verificando preenchimento dos campos considerados obrigatórios
	if (p_login = '' or p_firstName = '' or p_lastName = '' or p_email = '' or p_fonenumber = '' ) then
	    set p_msg_retorno = 'Campos obrigatórios devem ser preenchidos. Verifique.';
        leave sp;
	end if;
	
    # verificando se o e-mail já existe no sistema para outro usuario
	select 1 into v_Exist from tb_user where email = p_email and userid <> p_userid;
	if v_Exist = 1 then
	   set p_msg_retorno =  'e-mail já cadastrado no sistema. Verifique.';
       leave sp;
	end if;
    
    START TRANSACTION;
	
    # Coletando as informações existentes do usuário
    
    select CONCAT ( 'Login: ', login, ' FirstName: ', firstname, ' LastName: ', lastname, 
                    ' Regional Council Code: ', regionalcouncilcode, ' email: ',  email, ' FoneNumber: ', fonenumber)
			into v_dadosOriginais
	from tb_user where userid = p_userid;
    
    set v_dadosAlterados = CONCAT ( 'Login: ', p_login, ' FirstName: ', p_firstname, ' LastName: ', p_lastname, 
                    ' Regional Council Code: ', p_regionalcouncilcode, ' email: ',  p_email, ' FoneNumber: ', p_fonenumber);
    
	Update tb_user
    set firstname = p_firstName, 
		lastname = p_lastName, 
        regionalcouncilcode = p_regionalCouncilCode, 
        password = p_Password,  
        email = p_email, 
        fonenumber = p_fonenumber;
        
    # registrando a informação de notificação de alteração do usuario 
    INSERT INTO tb_notificationrecord (
			userid, profileid, hospitalunitid, tablename, rowdid, changedon, operation, log)
            values (p_adminid, p_admingrouproleid, p_adminhospitalunitid, 'tb_user', p_userid, now(), 'A', CONCAT('Alteraçao de dados de Usuario de ', v_dadosOriginais, ' para ', v_dadosAlterados));

             
    COMMIT;
	
		
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getTotalMedicalRecordHospitalUnit` (`p_hospitalUnitid` INTEGER, `p_questionnaireid` INTEGER) RETURNS INT(11) BEGIN
#========================================================================================================================
#== Função criada para verificar se já existem prontuários/registros associados a um determinado hospital
#== Retornar o total de questionários lançados até a data
#== Criada em 07 dez 2020
#========================================================================================================================

declare v_totalRecord integer;

	select count(*) into v_totalRecord from tb_AssessmentQuestionnaire
				where hospitalUnitId = p_hospitalUnitId and
					  questionnaireid = p_questionnaireId;
                      
	if v_totalRecord is null then
       set v_totalRecord = 0;
	end if;
       
	RETURN v_totalRecord;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ontologyuri` (`ontologyacronym` VARCHAR(500), `tablename` VARCHAR(500), `identifier` INTEGER) RETURNS VARCHAR(500) CHARSET utf8 BEGIN
   declare v_ontologyURI character varying (255);
   
	  
   SELECT t3.ontologyuri into v_ontologyURI
   from 
       tb_QuestionnairePartsTable t2, tb_QuestionnairePartsOntology t3, tb_ontology t4
   where
	t4.acronym = ontologyAcronym and -- Identifica a ontologia que se deseja relacionar
	t2.description = tableName and
	t3.ontologyID = t4.OntologyID and
	t3.questionnairepartstableid = t2.questionnairepartstableid and
	t3.questionnairepartsid = identifier;
  
    if (v_ontologyURI is null) then  
        SET v_ontologyURI = '';
    END IF;
	  
    RETURN v_ontologyURI;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `translate` (`lng` VARCHAR(255), `val` VARCHAR(500)) RETURNS VARCHAR(500) CHARSET utf8 BEGIN
   declare descriptionLNG varchar (500);
 
	
      select t1.descriptionlang into descriptionLNG
      from tb_multilanguage t1, tb_language t2 
	  where t2.description = lng and t1.languageId = t2.languageID and upper(t1.description) = upper(val);
  
      if (descriptionLNG is null) then  
	    SET descriptionLNG = '';
	  END IF;
	  
      RETURN descriptionLNG;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tb_assessmentquestionnaire`
--

CREATE TABLE `tb_assessmentquestionnaire` (
  `participantID` int(10) NOT NULL COMMENT '(pt-br)  Chave estrangeira para a tabela tb_Patient.\r\n(en) Foreign key to the tb_Patient table.',
  `hospitalUnitID` int(10) NOT NULL COMMENT '(pt-br) Chave estrangeira para tabela tb_HospitalUnit.\r\n(en) Foreign key for the tp_HospitalUnit table.',
  `questionnaireID` int(10) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_assessmentquestionnaire`
--

INSERT INTO `tb_assessmentquestionnaire` (`participantID`, `hospitalUnitID`, `questionnaireID`) VALUES
(88, 1, 1),
(89, 1, 1),
(90, 1, 1),
(91, 1, 1),
(92, 1, 1),
(93, 1, 1),
(94, 1, 1),
(95, 1, 1),
(96, 1, 1),
(97, 1, 1),
(98, 1, 1),
(99, 1, 1),
(100, 1, 1),
(101, 1, 1),
(102, 1, 1),
(103, 1, 1),
(104, 1, 1),
(105, 1, 1),
(106, 1, 1),
(107, 1, 1),
(108, 1, 1),
(109, 1, 1),
(110, 1, 1),
(111, 1, 1),
(112, 1, 1),
(113, 1, 1),
(114, 1, 1),
(115, 1, 1),
(116, 1, 1),
(117, 1, 1),
(118, 1, 1),
(119, 1, 1),
(120, 1, 1),
(121, 1, 1),
(122, 1, 1),
(123, 1, 1),
(124, 1, 1),
(125, 1, 1),
(126, 1, 1),
(127, 1, 1),
(128, 1, 1),
(129, 1, 1),
(130, 1, 1),
(131, 1, 1),
(132, 1, 1),
(133, 1, 1),
(134, 1, 1),
(135, 1, 1),
(136, 1, 1),
(137, 1, 1),
(138, 1, 1),
(139, 1, 1),
(140, 1, 1),
(141, 1, 1),
(142, 1, 1),
(143, 1, 1),
(144, 1, 1),
(145, 1, 1),
(146, 1, 1),
(147, 1, 1),
(148, 1, 1),
(149, 1, 1),
(150, 1, 1),
(151, 1, 1),
(152, 1, 1),
(153, 1, 1),
(154, 1, 1),
(155, 1, 1),
(156, 1, 1),
(157, 1, 1),
(158, 1, 1),
(159, 1, 1),
(160, 1, 1),
(161, 1, 1),
(162, 1, 1),
(163, 1, 1),
(164, 1, 1),
(165, 1, 1),
(166, 1, 1),
(167, 1, 1),
(168, 1, 1),
(169, 1, 1),
(170, 1, 1),
(172, 1, 1),
(173, 1, 1),
(174, 1, 1),
(175, 1, 1),
(176, 1, 1),
(177, 1, 1),
(178, 2, 1),
(179, 1, 1),
(180, 1, 1),
(181, 1, 1),
(182, 1, 1),
(183, 1, 1),
(184, 1, 1),
(185, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `tb_crfforms`
--

CREATE TABLE `tb_crfforms` (
  `crfFormsID` int(10) NOT NULL,
  `questionnaireID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL COMMENT '(pt-br) Descrição .\r\n(en) description.',
  `crfformsStatusID` int(10) NOT NULL,
  `lastModification` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `creationDate` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='(pt-br)\r\ntb_CRFForms identifica o tipo do formulario refere-se ao Questionnaire Subsection da Ontologia:\r\nAdmissão - Modulo 1\r\nAcompanhamento - Modulo 2\r\nDesfecho - Modulo 3\r\n(en)\r\ntb_CRFForms identifies the type of the form refers to the Questionnaire Subsection of Ontology: Admission - Module 1 Monitoring - Module 2 Outcome - Module 3';

--
-- Dumping data for table `tb_crfforms`
--

INSERT INTO `tb_crfforms` (`crfFormsID`, `questionnaireID`, `description`, `crfformsStatusID`, `lastModification`, `creationDate`) VALUES
(1, 1, 'Admission form', 1, '2021-11-17 21:19:53', '2021-11-17 21:20:38'),
(2, 1, 'Follow-up', 1, '2021-11-17 21:19:44', '2021-11-17 21:20:38'),
(3, 1, 'Discharge/death form', 1, '2021-11-17 21:19:51', '2021-11-17 21:20:38');

-- --------------------------------------------------------

--
-- Table structure for table `tb_crfformsstatus`
--

CREATE TABLE `tb_crfformsstatus` (
  `crfformsStatusID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL,
  `creationDate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `tb_crfformsstatus`
--

INSERT INTO `tb_crfformsstatus` (`crfformsStatusID`, `description`, `creationDate`) VALUES
(1, 'Finalized', '2021-11-17 21:10:58'),
(2, 'New', '2021-11-17 21:11:08');

-- --------------------------------------------------------

--
-- Table structure for table `tb_formrecord`
--

CREATE TABLE `tb_formrecord` (
  `formRecordID` int(10) NOT NULL,
  `participantID` int(10) NOT NULL,
  `hospitalUnitID` int(10) NOT NULL,
  `questionnaireID` int(10) NOT NULL,
  `crfFormsID` int(10) NOT NULL,
  `dtRegistroForm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_formrecord`
--

INSERT INTO `tb_formrecord` (`formRecordID`, `participantID`, `hospitalUnitID`, `questionnaireID`, `crfFormsID`, `dtRegistroForm`) VALUES
(1, 116, 1, 1, 1, '2020-11-01 13:38:16'),
(2, 116, 1, 1, 2, '2020-11-01 13:38:16'),
(3, 116, 1, 1, 3, '2020-11-01 13:38:16'),
(4, 98, 1, 1, 1, '2020-11-01 13:38:16'),
(5, 98, 1, 1, 2, '2020-11-01 13:38:16'),
(6, 98, 1, 1, 3, '2020-11-01 13:38:16'),
(7, 120, 1, 1, 1, '2020-11-01 13:38:16'),
(8, 120, 1, 1, 2, '2020-11-01 13:38:16'),
(9, 120, 1, 1, 3, '2020-11-01 13:38:16'),
(10, 93, 1, 1, 1, '2020-11-01 13:38:16'),
(11, 93, 1, 1, 2, '2020-11-01 13:38:16'),
(12, 93, 1, 1, 3, '2020-11-01 13:38:16'),
(13, 122, 1, 1, 1, '2020-11-01 13:38:16'),
(14, 122, 1, 1, 2, '2020-11-01 13:38:16'),
(15, 122, 1, 1, 3, '2020-11-01 13:38:16'),
(16, 123, 1, 1, 1, '2020-11-01 13:38:16'),
(17, 123, 1, 1, 2, '2020-11-01 13:38:16'),
(18, 123, 1, 1, 3, '2020-11-01 13:38:16'),
(19, 105, 1, 1, 1, '2020-11-01 13:38:16'),
(20, 105, 1, 1, 2, '2020-11-01 13:38:16'),
(21, 105, 1, 1, 3, '2020-11-01 13:38:16'),
(22, 113, 1, 1, 1, '2020-11-01 13:38:16'),
(23, 113, 1, 1, 2, '2020-11-01 13:38:16'),
(24, 113, 1, 1, 3, '2020-11-01 13:38:16'),
(25, 104, 1, 1, 1, '2020-11-01 13:38:16'),
(26, 104, 1, 1, 2, '2020-11-01 13:38:16'),
(27, 104, 1, 1, 3, '2020-11-01 13:38:16'),
(28, 124, 1, 1, 1, '2020-11-01 13:38:16'),
(29, 124, 1, 1, 2, '2020-11-01 13:38:16'),
(30, 124, 1, 1, 3, '2020-11-01 13:38:16'),
(31, 125, 1, 1, 1, '2020-11-01 13:38:16'),
(32, 125, 1, 1, 2, '2020-11-01 13:38:16'),
(33, 125, 1, 1, 3, '2020-11-01 13:38:16'),
(34, 126, 1, 1, 1, '2020-11-01 13:38:16'),
(35, 126, 1, 1, 2, '2020-11-01 13:38:16'),
(36, 126, 1, 1, 3, '2020-11-01 13:38:16'),
(37, 127, 1, 1, 1, '2020-11-01 13:38:16'),
(38, 127, 1, 1, 2, '2020-11-01 13:38:16'),
(39, 127, 1, 1, 3, '2020-11-01 13:38:16'),
(40, 99, 1, 1, 1, '2020-11-01 13:38:16'),
(41, 99, 1, 1, 2, '2020-11-01 13:38:16'),
(42, 99, 1, 1, 3, '2020-11-01 13:38:16'),
(43, 128, 1, 1, 1, '2020-11-01 13:38:16'),
(44, 128, 1, 1, 2, '2020-11-01 13:38:16'),
(45, 128, 1, 1, 3, '2020-11-01 13:38:16'),
(46, 129, 1, 1, 1, '2020-11-01 13:38:16'),
(47, 129, 1, 1, 2, '2020-11-01 13:38:16'),
(48, 129, 1, 1, 3, '2020-11-01 13:38:16'),
(49, 130, 1, 1, 1, '2020-11-01 13:38:16'),
(50, 130, 1, 1, 2, '2020-11-01 13:38:16'),
(51, 130, 1, 1, 3, '2020-11-01 13:38:16'),
(52, 131, 1, 1, 1, '2020-11-01 13:38:16'),
(53, 131, 1, 1, 2, '2020-11-01 13:38:16'),
(54, 131, 1, 1, 3, '2020-11-01 13:38:16'),
(55, 95, 1, 1, 1, '2020-11-01 13:38:16'),
(56, 95, 1, 1, 2, '2020-11-01 13:38:16'),
(57, 95, 1, 1, 3, '2020-11-01 13:38:16'),
(58, 132, 1, 1, 1, '2020-11-01 13:38:16'),
(59, 132, 1, 1, 2, '2020-11-01 13:38:16'),
(60, 132, 1, 1, 3, '2020-11-01 13:38:16'),
(61, 133, 1, 1, 1, '2020-11-01 13:38:16'),
(62, 133, 1, 1, 2, '2020-11-01 13:38:16'),
(63, 133, 1, 1, 3, '2020-11-01 13:38:16'),
(64, 94, 1, 1, 1, '2020-11-01 13:38:16'),
(65, 94, 1, 1, 2, '2020-11-01 13:38:16'),
(66, 94, 1, 1, 3, '2020-11-01 13:38:16'),
(67, 101, 1, 1, 1, '2020-11-01 13:38:16'),
(68, 101, 1, 1, 2, '2020-11-01 13:38:16'),
(69, 101, 1, 1, 3, '2020-11-01 13:38:16'),
(70, 134, 1, 1, 1, '2020-11-01 13:38:16'),
(71, 134, 1, 1, 2, '2020-11-01 13:38:16'),
(72, 134, 1, 1, 3, '2020-11-01 13:38:16'),
(73, 135, 1, 1, 1, '2020-11-01 13:38:16'),
(74, 135, 1, 1, 2, '2020-11-01 13:38:16'),
(75, 135, 1, 1, 3, '2020-11-01 13:38:16'),
(76, 136, 1, 1, 1, '2020-11-01 13:38:16'),
(77, 136, 1, 1, 2, '2020-11-01 13:38:16'),
(78, 136, 1, 1, 3, '2020-11-01 13:38:16'),
(79, 119, 1, 1, 1, '2020-11-01 13:38:16'),
(80, 119, 1, 1, 2, '2020-11-01 13:38:16'),
(81, 119, 1, 1, 3, '2020-11-01 13:38:16'),
(82, 88, 1, 1, 1, '2020-11-01 13:38:16'),
(83, 88, 1, 1, 2, '2020-11-01 13:38:16'),
(84, 88, 1, 1, 3, '2020-11-01 13:38:16'),
(85, 137, 1, 1, 1, '2020-11-01 13:38:16'),
(86, 137, 1, 1, 2, '2020-11-01 13:38:16'),
(87, 137, 1, 1, 3, '2020-11-01 13:38:16'),
(88, 138, 1, 1, 1, '2020-11-01 13:38:16'),
(89, 138, 1, 1, 2, '2020-11-01 13:38:16'),
(90, 138, 1, 1, 3, '2020-11-01 13:38:16'),
(91, 139, 1, 1, 1, '2020-11-01 13:38:16'),
(92, 139, 1, 1, 2, '2020-11-01 13:38:16'),
(93, 139, 1, 1, 3, '2020-11-01 13:38:16'),
(94, 97, 1, 1, 1, '2020-11-01 13:38:16'),
(95, 97, 1, 1, 2, '2020-11-01 13:38:16'),
(96, 97, 1, 1, 3, '2020-11-01 13:38:16'),
(97, 96, 1, 1, 1, '2020-11-01 13:38:16'),
(98, 96, 1, 1, 2, '2020-11-01 13:38:16'),
(99, 96, 1, 1, 3, '2020-11-01 13:38:16'),
(100, 140, 1, 1, 1, '2020-11-01 13:38:16'),
(101, 140, 1, 1, 2, '2020-11-01 13:38:16'),
(102, 140, 1, 1, 3, '2020-11-01 13:38:16'),
(103, 102, 1, 1, 1, '2020-11-01 13:38:16'),
(104, 102, 1, 1, 2, '2020-11-01 13:38:16'),
(105, 102, 1, 1, 3, '2020-11-01 13:38:16'),
(106, 141, 1, 1, 1, '2020-11-01 13:38:16'),
(107, 141, 1, 1, 2, '2020-11-01 13:38:16'),
(108, 141, 1, 1, 3, '2020-11-01 13:38:16'),
(109, 111, 1, 1, 1, '2020-11-01 13:38:16'),
(110, 111, 1, 1, 2, '2020-11-01 13:38:16'),
(111, 111, 1, 1, 3, '2020-11-01 13:38:16'),
(112, 117, 1, 1, 1, '2020-11-01 13:38:16'),
(113, 117, 1, 1, 2, '2020-11-01 13:38:16'),
(114, 117, 1, 1, 3, '2020-11-01 13:38:16'),
(115, 118, 1, 1, 1, '2020-11-01 13:38:16'),
(116, 118, 1, 1, 2, '2020-11-01 13:38:16'),
(117, 118, 1, 1, 3, '2020-11-01 13:38:16'),
(118, 110, 1, 1, 1, '2020-11-01 13:38:16'),
(119, 110, 1, 1, 2, '2020-11-01 13:38:16'),
(120, 110, 1, 1, 3, '2020-11-01 13:38:16'),
(121, 143, 1, 1, 1, '2020-11-01 13:38:16'),
(122, 143, 1, 1, 2, '2020-11-01 13:38:16'),
(123, 143, 1, 1, 3, '2020-11-01 13:38:16'),
(124, 142, 1, 1, 1, '2020-11-01 13:38:16'),
(125, 142, 1, 1, 2, '2020-11-01 13:38:16'),
(126, 142, 1, 1, 3, '2020-11-01 13:38:16'),
(127, 144, 1, 1, 1, '2020-11-01 13:38:16'),
(128, 144, 1, 1, 2, '2020-11-01 13:38:16'),
(129, 144, 1, 1, 3, '2020-11-01 13:38:16'),
(130, 145, 1, 1, 1, '2020-11-01 13:38:16'),
(131, 145, 1, 1, 2, '2020-11-01 13:38:16'),
(132, 145, 1, 1, 3, '2020-11-01 13:38:16'),
(133, 146, 1, 1, 1, '2020-11-01 13:38:16'),
(134, 146, 1, 1, 2, '2020-11-01 13:38:16'),
(135, 146, 1, 1, 3, '2020-11-01 13:38:16'),
(136, 147, 1, 1, 1, '2020-11-01 13:38:16'),
(137, 147, 1, 1, 2, '2020-11-01 13:38:16'),
(138, 147, 1, 1, 3, '2020-11-01 13:38:16'),
(139, 148, 1, 1, 1, '2020-11-01 13:38:16'),
(140, 148, 1, 1, 2, '2020-11-01 13:38:16'),
(141, 148, 1, 1, 3, '2020-11-01 13:38:16'),
(142, 112, 1, 1, 1, '2020-11-01 13:38:16'),
(143, 112, 1, 1, 2, '2020-11-01 13:38:16'),
(144, 112, 1, 1, 3, '2020-11-01 13:38:16'),
(145, 90, 1, 1, 1, '2020-11-01 13:38:16'),
(146, 90, 1, 1, 2, '2020-11-01 13:38:16'),
(147, 90, 1, 1, 3, '2020-11-01 13:38:16'),
(148, 92, 1, 1, 1, '2020-11-01 13:38:16'),
(149, 92, 1, 1, 2, '2020-11-01 13:38:16'),
(150, 92, 1, 1, 3, '2020-11-01 13:38:16'),
(151, 107, 1, 1, 1, '2020-11-01 13:38:16'),
(152, 107, 1, 1, 2, '2020-11-01 13:38:16'),
(153, 107, 1, 1, 3, '2020-11-01 13:38:16'),
(154, 115, 1, 1, 1, '2020-11-01 13:38:16'),
(155, 115, 1, 1, 2, '2020-11-01 13:38:16'),
(156, 115, 1, 1, 3, '2020-11-01 13:38:16'),
(157, 150, 1, 1, 1, '2020-11-01 13:38:16'),
(158, 150, 1, 1, 2, '2020-11-01 13:38:16'),
(159, 150, 1, 1, 3, '2020-11-01 13:38:16'),
(160, 149, 1, 1, 1, '2020-11-01 13:38:16'),
(161, 149, 1, 1, 2, '2020-11-01 13:38:16'),
(162, 149, 1, 1, 3, '2020-11-01 13:38:16'),
(163, 152, 1, 1, 1, '2020-11-01 13:38:16'),
(164, 152, 1, 1, 2, '2020-11-01 13:38:16'),
(165, 152, 1, 1, 3, '2020-11-01 13:38:16'),
(166, 151, 1, 1, 1, '2020-11-01 13:38:16'),
(167, 151, 1, 1, 2, '2020-11-01 13:38:16'),
(168, 151, 1, 1, 3, '2020-11-01 13:38:16'),
(169, 109, 1, 1, 1, '2020-11-01 13:38:16'),
(170, 109, 1, 1, 2, '2020-11-01 13:38:16'),
(171, 109, 1, 1, 3, '2020-11-01 13:38:16'),
(172, 153, 1, 1, 1, '2020-11-01 13:38:16'),
(173, 153, 1, 1, 2, '2020-11-01 13:38:16'),
(174, 153, 1, 1, 3, '2020-11-01 13:38:16'),
(175, 154, 1, 1, 1, '2020-11-01 13:38:16'),
(176, 154, 1, 1, 2, '2020-11-01 13:38:16'),
(177, 154, 1, 1, 3, '2020-11-01 13:38:16'),
(178, 156, 1, 1, 1, '2020-11-01 13:38:16'),
(179, 156, 1, 1, 2, '2020-11-01 13:38:16'),
(180, 156, 1, 1, 3, '2020-11-01 13:38:16'),
(181, 157, 1, 1, 1, '2020-11-01 13:38:16'),
(182, 157, 1, 1, 2, '2020-11-01 13:38:16'),
(183, 157, 1, 1, 3, '2020-11-01 13:38:16'),
(184, 103, 1, 1, 1, '2020-11-01 13:38:16'),
(185, 103, 1, 1, 2, '2020-11-01 13:38:16'),
(186, 103, 1, 1, 3, '2020-11-01 13:38:16'),
(187, 155, 1, 1, 1, '2020-11-01 13:38:16'),
(188, 155, 1, 1, 2, '2020-11-01 13:38:16'),
(189, 155, 1, 1, 3, '2020-11-01 13:38:16'),
(190, 158, 1, 1, 1, '2020-11-01 13:38:16'),
(191, 158, 1, 1, 2, '2020-11-01 13:38:16'),
(192, 158, 1, 1, 3, '2020-11-01 13:38:16'),
(193, 91, 1, 1, 1, '2020-11-01 13:38:16'),
(194, 91, 1, 1, 2, '2020-11-01 13:38:16'),
(195, 91, 1, 1, 3, '2020-11-01 13:38:16'),
(196, 106, 1, 1, 1, '2020-11-01 13:38:16'),
(197, 106, 1, 1, 2, '2020-11-01 13:38:16'),
(198, 106, 1, 1, 3, '2020-11-01 13:38:16'),
(199, 159, 1, 1, 1, '2020-11-01 13:38:16'),
(200, 159, 1, 1, 2, '2020-11-01 13:38:16'),
(201, 159, 1, 1, 3, '2020-11-01 13:38:16'),
(202, 100, 1, 1, 1, '2020-11-01 13:38:16'),
(203, 100, 1, 1, 2, '2020-11-01 13:38:16'),
(204, 100, 1, 1, 3, '2020-11-01 13:38:16'),
(205, 160, 1, 1, 1, '2020-11-01 13:38:16'),
(206, 160, 1, 1, 2, '2020-11-01 13:38:16'),
(207, 160, 1, 1, 3, '2020-11-01 13:38:16'),
(208, 161, 1, 1, 1, '2020-11-01 13:38:16'),
(209, 161, 1, 1, 2, '2020-11-01 13:38:16'),
(210, 161, 1, 1, 3, '2020-11-01 13:38:16'),
(211, 162, 1, 1, 1, '2020-11-01 13:38:16'),
(212, 162, 1, 1, 2, '2020-11-01 13:38:16'),
(213, 162, 1, 1, 3, '2020-11-01 13:38:16'),
(214, 108, 1, 1, 1, '2020-11-01 13:38:16'),
(215, 108, 1, 1, 2, '2020-11-01 13:38:16'),
(216, 108, 1, 1, 3, '2020-11-01 13:38:16'),
(217, 114, 1, 1, 1, '2020-11-01 13:38:16'),
(218, 114, 1, 1, 2, '2020-11-01 13:38:16'),
(219, 114, 1, 1, 3, '2020-11-01 13:38:16'),
(220, 89, 1, 1, 1, '2020-11-01 13:38:16'),
(221, 89, 1, 1, 2, '2020-11-01 13:38:16'),
(222, 89, 1, 1, 3, '2020-11-01 13:38:16'),
(223, 121, 1, 1, 1, '2020-11-01 13:38:16'),
(224, 121, 1, 1, 2, '2020-11-01 13:38:16'),
(225, 121, 1, 1, 3, '2020-11-01 13:38:16'),
(226, 163, 1, 1, 1, '2020-11-01 13:38:16'),
(227, 163, 1, 1, 2, '2020-11-01 13:38:16'),
(228, 163, 1, 1, 3, '2020-11-01 13:38:16'),
(229, 164, 1, 1, 1, '2020-11-01 13:38:16'),
(230, 164, 1, 1, 2, '2020-11-01 13:38:16'),
(231, 164, 1, 1, 3, '2020-11-01 13:38:16'),
(232, 165, 1, 1, 1, '2020-11-01 13:38:16'),
(233, 165, 1, 1, 2, '2020-11-01 13:38:16'),
(234, 165, 1, 1, 3, '2020-11-01 13:38:16'),
(235, 166, 1, 1, 1, '2020-11-01 13:38:16'),
(236, 166, 1, 1, 2, '2020-11-01 13:38:16'),
(237, 166, 1, 1, 3, '2020-11-01 13:38:16'),
(238, 168, 1, 1, 1, '2020-12-08 15:29:18'),
(239, 88, 1, 1, 2, '2021-01-26 19:55:52'),
(240, 88, 1, 1, 2, '2021-01-26 20:00:54'),
(241, 88, 1, 1, 2, '2021-01-26 20:19:55'),
(242, 88, 1, 1, 2, '2021-02-02 15:07:45'),
(243, 88, 1, 1, 2, '2021-02-02 15:10:41'),
(244, 88, 1, 1, 1, '2021-02-02 15:13:37'),
(245, 95, 1, 1, 2, '2021-02-08 19:42:29'),
(246, 181, 1, 1, 1, '2021-02-23 21:25:47'),
(249, 89, 1, 1, 1, '2021-03-02 15:06:06'),
(250, 89, 1, 1, 2, '2021-03-02 17:22:43'),
(251, 89, 1, 1, 2, '2021-03-02 18:00:51'),
(252, 89, 1, 1, 2, '2021-03-02 18:05:07'),
(253, 89, 1, 1, 3, '2021-03-02 18:20:40'),
(254, 89, 1, 1, 1, '2021-03-03 21:49:55'),
(255, 89, 1, 1, 2, '2021-03-03 21:51:33'),
(256, 89, 1, 1, 2, '2021-03-16 17:02:42'),
(257, 88, 1, 1, 2, '2021-04-30 18:30:23');

-- --------------------------------------------------------

--
-- Table structure for table `tb_grouprole`
--

CREATE TABLE `tb_grouprole` (
  `groupRoleID` bigint(20) UNSIGNED NOT NULL,
  `description` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_grouprole`
--

INSERT INTO `tb_grouprole` (`groupRoleID`, `description`) VALUES
(1, 'Administrador'),
(2, 'ETL - Arquivos'),
(3, 'ETL - BD a BD'),
(4, 'Gestor de Ontologia'),
(5, 'Gestor de Repositório'),
(6, 'Notificador Médico'),
(7, 'Notificador Profissional de Saúde');

-- --------------------------------------------------------

--
-- Table structure for table `tb_grouprolepermission`
--

CREATE TABLE `tb_grouprolepermission` (
  `groupRoleID` int(11) NOT NULL,
  `permissionID` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tb_hospitalunit`
--

CREATE TABLE `tb_hospitalunit` (
  `hospitalUnitID` int(10) NOT NULL,
  `hospitalUnitName` varchar(500) NOT NULL COMMENT '(pt-br) Nome da unidade hospitalar.\r\n(en) Name of the hospital unit.'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='(pt-br) Tabela para identificação de unidades hospitalares.\r\n(en) Table for hospital units identification.';

--
-- Dumping data for table `tb_hospitalunit`
--

INSERT INTO `tb_hospitalunit` (`hospitalUnitID`, `hospitalUnitName`) VALUES
(1, 'Hospital Universitário Gaffrée e Guinle - HUGG'),
(2, 'Hospital municipal São José - Duque de Caxias');

-- --------------------------------------------------------

--
-- Table structure for table `tb_language`
--

CREATE TABLE `tb_language` (
  `languageID` int(11) NOT NULL,
  `description` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_language`
--

INSERT INTO `tb_language` (`languageID`, `description`) VALUES
(1, 'pt-br');

-- --------------------------------------------------------

--
-- Table structure for table `tb_listofvalues`
--

CREATE TABLE `tb_listofvalues` (
  `listOfValuesID` int(10) NOT NULL,
  `listTypeID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL COMMENT '(pt-br) Descrição.\r\n(en) description.'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='(pt-br) Representa todos os valores padronizados do formulário.\r\n(en) Represents all standard values on the form.';

--
-- Dumping data for table `tb_listofvalues`
--

INSERT INTO `tb_listofvalues` (`listOfValuesID`, `listTypeID`, `description`) VALUES
(1, 1, 'Interferon alpha'),
(2, 1, 'Interferon beta'),
(3, 1, 'Lopinavir/Ritonavir'),
(4, 1, 'Neuraminidase inhibitor'),
(5, 1, 'Ribavirin'),
(6, 2, 'Alert'),
(7, 2, 'Pain'),
(8, 2, 'Unresponsive'),
(9, 2, 'Verbal'),
(10, 3, 'MERS-CoV'),
(11, 3, 'SARS-CoV-2'),
(12, 4, 'Inhaled'),
(13, 4, 'Intravenous'),
(14, 4, 'Oral'),
(15, 5, 'Afghanistan'),
(16, 5, 'Aland Islands'),
(17, 5, 'Albania'),
(18, 5, 'Algeria'),
(19, 5, 'American Samoa'),
(20, 5, 'Andorra'),
(21, 5, 'Angola'),
(22, 5, 'Anguilla'),
(23, 5, 'Antarctica'),
(24, 5, 'Antigua and Barbuda'),
(25, 5, 'Argentina'),
(26, 5, 'Armenia'),
(27, 5, 'Aruba'),
(28, 5, 'Australia'),
(29, 5, 'Austria'),
(30, 5, 'Azerbaijan'),
(31, 5, 'Bahamas'),
(32, 5, 'Bahrain'),
(33, 5, 'Bangladesh'),
(34, 5, 'Barbados'),
(35, 5, 'Belarus'),
(36, 5, 'Belgium'),
(37, 5, 'Belize'),
(38, 5, 'Benin'),
(39, 5, 'Bermuda'),
(40, 5, 'Bhutan'),
(41, 5, 'Bolivia, Plurinational State of'),
(42, 5, 'Bosnia and Herzegovina'),
(43, 5, 'Botswana'),
(44, 5, 'Bouvet Island'),
(45, 5, 'Brazil'),
(46, 5, 'British Indian Ocean Territory'),
(47, 5, 'Brunei Darussalam'),
(48, 5, 'Bulgaria'),
(49, 5, 'Burkina Faso'),
(50, 5, 'Burundi'),
(51, 5, 'Cambodia'),
(52, 5, 'Cameroon'),
(53, 5, 'Canada'),
(54, 5, 'Cape Verde'),
(55, 5, 'Cayman Islands'),
(56, 5, 'Central African Republic'),
(57, 5, 'Chad'),
(58, 5, 'Chile'),
(59, 5, 'China'),
(60, 5, 'Christmas Island'),
(61, 5, 'Cocos (Keeling) Islands'),
(62, 5, 'Colombia'),
(63, 5, 'Comoros'),
(64, 5, 'Congo'),
(65, 5, 'Congo, the Democratic Republic of the'),
(66, 5, 'Cook Islands'),
(67, 5, 'Costa Rica'),
(68, 5, 'Cote d\'Ivoire'),
(69, 5, 'Croatia'),
(70, 5, 'Cuba'),
(71, 5, 'Cyprus'),
(72, 5, 'Czech Republic'),
(73, 5, 'Denmark'),
(74, 5, 'Djibouti'),
(75, 5, 'Dominica'),
(76, 5, 'Dominican Republic'),
(77, 5, 'Ecuador'),
(78, 5, 'Egypt'),
(79, 5, 'El Salvador'),
(80, 5, 'Equatorial Guinea'),
(81, 5, 'Eritrea'),
(82, 5, 'Estonia'),
(83, 5, 'Ethiopia'),
(84, 5, 'Falkland Islands (Malvinas)'),
(85, 5, 'Faroe Islands'),
(86, 5, 'Fiji'),
(87, 5, 'Finland'),
(88, 5, 'France'),
(89, 5, 'French Guiana'),
(90, 5, 'French Polynesia'),
(91, 5, 'French Southern Territories'),
(92, 5, 'Gabon'),
(93, 5, 'Gambia'),
(94, 5, 'Georgia'),
(95, 5, 'Germany'),
(96, 5, 'Ghana'),
(97, 5, 'Gibraltar'),
(98, 5, 'Greece'),
(99, 5, 'Greenland'),
(100, 5, 'Grenada'),
(101, 5, 'Guadeloupe'),
(102, 5, 'Guam'),
(103, 5, 'Guatemala'),
(104, 5, 'Guernsey'),
(105, 5, 'Guinea'),
(106, 5, 'Guinea-Bissau'),
(107, 5, 'Guyana'),
(108, 5, 'Haiti'),
(109, 5, 'Heard Island and McDonald Islands'),
(110, 5, 'Holy See (Vatican City State)'),
(111, 5, 'Honduras'),
(112, 5, 'Hong Kong'),
(113, 5, 'Hungary'),
(114, 5, 'Iceland'),
(115, 5, 'India'),
(116, 5, 'Indonesia'),
(117, 5, 'Iran, Islamic Republic of'),
(118, 5, 'Iraq'),
(119, 5, 'Ireland'),
(120, 5, 'Isle of Man'),
(121, 5, 'Israel'),
(122, 5, 'Italy'),
(123, 5, 'Jamaica'),
(124, 5, 'Japan'),
(125, 5, 'Jersey'),
(126, 5, 'Jordan'),
(127, 5, 'Kazakhstan'),
(128, 5, 'Kenya'),
(129, 5, 'Kiribati'),
(130, 5, 'Korea, Democratic People\'\'s Republic of'),
(131, 5, 'Korea, Republic of'),
(132, 5, 'Kuwait'),
(133, 5, 'Kyrgyzstan'),
(134, 5, 'Lao People\'s Democratic Republic'),
(135, 5, 'Latvia'),
(136, 5, 'Lebanon'),
(137, 5, 'Lesotho'),
(138, 5, 'Liberia'),
(139, 5, 'Libyan Arab Jamahiriya'),
(140, 5, 'Liechtenstein'),
(141, 5, 'Lithuania'),
(142, 5, 'Luxembourg'),
(143, 5, 'Macao'),
(144, 5, 'Macedonia, the former Yugoslav Republic of'),
(145, 5, 'Madagascar'),
(146, 5, 'Malawi'),
(147, 5, 'Malaysia'),
(148, 5, 'Maldives'),
(149, 5, 'Mali'),
(150, 5, 'Malta'),
(151, 5, 'Marshall Islands'),
(152, 5, 'Martinique'),
(153, 5, 'Mauritania'),
(154, 5, 'Mauritius'),
(155, 5, 'Mayotte'),
(156, 5, 'Mexico'),
(157, 5, 'Micronesia, Federated States of'),
(158, 5, 'Moldova, Republic of'),
(159, 5, 'Monaco'),
(160, 5, 'Mongolia'),
(161, 5, 'Montenegro'),
(162, 5, 'Montserrat'),
(163, 5, 'Morocco'),
(164, 5, 'Mozambique'),
(165, 5, 'Myanmar'),
(166, 5, 'Namibia'),
(167, 5, 'Nauru'),
(168, 5, 'Nepal'),
(169, 5, 'Netherlands'),
(170, 5, 'Netherlands Antilles'),
(171, 5, 'New Caledonia'),
(172, 5, 'New Zealand'),
(173, 5, 'Nicaragua'),
(174, 5, 'Niger'),
(175, 5, 'Nigeria'),
(176, 5, 'Niue'),
(177, 5, 'Norfolk Island'),
(178, 5, 'Northern Mariana Islands'),
(179, 5, 'Norway'),
(180, 5, 'Oman'),
(181, 5, 'Pakistan'),
(182, 5, 'Palau'),
(183, 5, 'Palestinian Territory, Occupied'),
(184, 5, 'Panama'),
(185, 5, 'Papua New Guinea'),
(186, 5, 'Paraguay'),
(187, 5, 'Peru'),
(188, 5, 'Philippines'),
(189, 5, 'Pitcairn'),
(190, 5, 'Poland'),
(191, 5, 'Portugal'),
(192, 5, 'Puerto Rico'),
(193, 5, 'Qatar'),
(194, 5, 'Reunion ﻿ Réunion'),
(195, 5, 'Romania'),
(196, 5, 'Russian Federation'),
(197, 5, 'Rwanda'),
(198, 5, 'Saint Barthélemy'),
(199, 5, 'Saint Helena'),
(200, 5, 'Saint Kitts and Nevis'),
(201, 5, 'Saint Lucia'),
(202, 5, 'Saint Martin (French part)'),
(203, 5, 'Saint Pierre and Miquelon'),
(204, 5, 'Saint Vincent and the Grenadines'),
(205, 5, 'Samoa'),
(206, 5, 'San Marino'),
(207, 5, 'Sao Tome and Principe'),
(208, 5, 'Saudi Arabia'),
(209, 5, 'Senegal'),
(210, 5, 'Serbia'),
(211, 5, 'Seychelles'),
(212, 5, 'Sierra Leone'),
(213, 5, 'Singapore'),
(214, 5, 'Slovakia'),
(215, 5, 'Slovenia'),
(216, 5, 'Solomon Islands'),
(217, 5, 'Somalia'),
(218, 5, 'South Africa'),
(219, 5, 'South Georgia and the South Sandwich Islands'),
(220, 5, 'Spain'),
(221, 5, 'Sri Lanka'),
(222, 5, 'Sudan'),
(223, 5, 'Suriname'),
(224, 5, 'Svalbard and Jan Mayen'),
(225, 5, 'Swaziland'),
(226, 5, 'Sweden'),
(227, 5, 'Switzerland'),
(228, 5, 'Syrian Arab Republic'),
(229, 5, 'Taiwan, Province of China'),
(230, 5, 'Tajikistan'),
(231, 5, 'Tanzania, United Republic of'),
(232, 5, 'Thailand'),
(233, 5, 'Timor-Leste'),
(234, 5, 'Togo'),
(235, 5, 'Tokelau'),
(236, 5, 'Tonga'),
(237, 5, 'Trinidad and Tobago'),
(238, 5, 'Tunisia'),
(239, 5, 'Turkey'),
(240, 5, 'Turkmenistan'),
(241, 5, 'Turks and Caicos Islands'),
(242, 5, 'Tuvalu'),
(243, 5, 'Uganda'),
(244, 5, 'Ukraine'),
(245, 5, 'United Arab Emirates'),
(246, 5, 'United Kingdom'),
(247, 5, 'United States'),
(248, 5, 'United States Minor Outlying Islands'),
(249, 5, 'Uruguay'),
(250, 5, 'Uzbekistan'),
(251, 5, 'Vanuatu'),
(252, 5, 'Venezuela, Bolivarian Republic of'),
(253, 5, 'Viet Nam'),
(254, 5, 'Virgin Islands, British'),
(255, 5, 'Virgin Islands, U.S.'),
(256, 5, 'Wallis and Futuna'),
(257, 5, 'Western Sahara'),
(258, 5, 'Yemen'),
(259, 5, 'Zambia'),
(260, 5, 'Zimbabwe'),
(261, 6, 'No'),
(262, 6, 'Unknown'),
(263, 6, 'Yes-not on ART'),
(264, 6, 'Yes-on ART'),
(265, 7, 'CPAP/NIV mask'),
(266, 7, 'HF nasal cannula'),
(267, 7, 'Mask'),
(268, 7, 'Mask with reservoir'),
(269, 7, 'Unknown'),
(270, 8, '>15 L/min'),
(271, 8, '1-5 L/min'),
(272, 8, '11-15 L/min'),
(273, 8, '6-10 L/min'),
(274, 8, 'Unknown'),
(275, 9, 'Death'),
(276, 9, 'Discharged alive'),
(277, 9, 'Hospitalized'),
(278, 9, 'Palliative discharge'),
(279, 9, 'Transfer to other facility'),
(280, 9, 'Unknown'),
(281, 10, 'Oxygen therapy'),
(282, 10, 'Room air'),
(283, 10, 'Unknown'),
(284, 13, 'Female'),
(285, 13, 'Male'),
(286, 13, 'Not Specified'),
(287, 14, 'Concentrator'),
(288, 14, 'Cylinder'),
(289, 14, 'Piped'),
(290, 14, 'Unknown'),
(291, 11, 'Not done'),
(292, 12, 'Better'),
(293, 12, 'Same as before illness'),
(294, 12, 'Unknown'),
(295, 12, 'Worse'),
(296, 15, 'No'),
(297, 15, 'Unknown'),
(298, 15, 'Yes'),
(299, 16, 'N/A'),
(300, 16, 'No'),
(301, 16, 'Unknown'),
(302, 16, 'Yes'),
(303, 11, 'Negative'),
(304, 11, 'Positive'),
(305, 1, 'Azithromycin'),
(306, 1, 'Chloroquine/hydroxychloroquine'),
(307, 1, 'Favipiravir');

-- --------------------------------------------------------

--
-- Table structure for table `tb_listtype`
--

CREATE TABLE `tb_listtype` (
  `listTypeID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL COMMENT '(pt-br) Descrição.\r\n(en) description.'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_listtype`
--

INSERT INTO `tb_listtype` (`listTypeID`, `description`) VALUES
(1, 'Antiviral list'),
(2, 'AVPU list'),
(3, 'Coronavirus list'),
(4, 'Corticosteroid list'),
(5, 'Country list'),
(6, 'HIV list'),
(7, 'Interface list'),
(8, 'O2 flow list'),
(9, 'Outcome list'),
(10, 'Outcome saturation list'),
(11, 'pnnotdone_list'),
(12, 'self_care_list'),
(13, 'sex at birth list'),
(14, 'Source of oxygen list'),
(15, 'ynu_list'),
(16, 'ynun_list');

-- --------------------------------------------------------

--
-- Table structure for table `tb_multilanguage`
--

CREATE TABLE `tb_multilanguage` (
  `languageID` int(11) NOT NULL,
  `description` varchar(300) NOT NULL,
  `descriptionLang` varchar(500) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_multilanguage`
--

INSERT INTO `tb_multilanguage` (`languageID`, `description`, `descriptionLang`) VALUES
(1, '>15 L/min', '> 15 L/min'),
(1, '1-5 L/min', '1-5 L/min'),
(1, '11-15 L/min', '11-15 L/min'),
(1, '6-10 L/min', '6-10 L/min'),
(1, 'A class of questions with date answers.', 'Uma classe de perguntas com respostas na forma de data.'),
(1, 'A history of self-reported feverishness or measured fever of ≥ 38 degrees Celsius', 'Um histórico de febre autorelatado ou febre medida de ≥ 38oC'),
(1, 'A question where the possible answers are: Yes, No or Unknown.', 'Uma pergunta onde a resposta pode ser: Sim, Não ou Desconhecido'),
(1, 'A single question of a questionaire. The rdfs:label of the sub-classes reflect the exact questions text from the WHO CRF.', 'Uma pergunta de um questionário. As propriedades rdfs:label das sub-classes refletem exatamente as perguntas definidas no FRC da OMS.'),
(1, 'A term used to indicate that information on a specific question or subject can not be provided because there is no relevance.', 'Termo usado para indicar que a resposta a uma pergunta ou a informação sobre um assunto não pode ser dada porque não é aplicável.'),
(1, 'Abdominal pain', 'Dor abdominal'),
(1, 'Ability to self-care at discharge versus before illness', 'Habilidade de autocuidado na alta em comparação com antes da doença'),
(1, 'Acute renal injury', 'Lesão renal aguda'),
(1, 'Acute Respiratory Distress Syndrome', 'Síndrome Respiratória Aguda'),
(1, 'Admission date at this facility', 'Data de admissão nesta unidade'),
(1, 'Admission form', 'Formulário de Admissão'),
(1, 'Afghanistan', 'Afghanistan'),
(1, 'Age', 'Idade'),
(1, 'Age (months)', 'Idade (meses)'),
(1, 'Age (years)', 'Idade (anos)'),
(1, 'Aland Islands', 'Aland Islands'),
(1, 'Albania', 'Albania'),
(1, 'Alert', 'Alerta'),
(1, 'Algeria', 'Algeria'),
(1, 'ALT/SGPT measurement', 'ALT/TGP'),
(1, 'Altered consciousness/confusion', 'Consciência alterada/confusão'),
(1, 'American Samoa', 'American Samoa'),
(1, 'Anaemia', 'Anemia'),
(1, 'Andorra', 'Andorra'),
(1, 'Angiotensin converting enzyme inhibitors (ACE inhibitors)', 'Inibidores da enzima de conversão da angiotensina (inibidores da ECA)'),
(1, 'Angiotensin II receptor blockers (ARBs)', 'Bloqueadores dos receptores de angiotensina II (BRAs)'),
(1, 'Angola', 'Angola'),
(1, 'Anguilla', 'Anguilla'),
(1, 'Antarctica', 'Antarctica'),
(1, 'Antibiotic', 'Antibiótico'),
(1, 'Antifungal agent', 'Agente antifungal'),
(1, 'Antigua and Barbuda', 'Antigua and Barbuda'),
(1, 'Antimalarial agent', 'Agente antimalárico'),
(1, 'Antiviral', 'Antiviral'),
(1, 'Antiviral list', 'Lista Antiviral'),
(1, 'APTT/APTR measurement', 'TTPA/APTR'),
(1, 'Argentina', 'Argentina'),
(1, 'Armenia', 'Armenia'),
(1, 'Aruba', 'Aruba'),
(1, 'Ashtma', 'Asma'),
(1, 'Asplenia', 'Asplenia'),
(1, 'AST/SGOT measurement', 'AST/TGO'),
(1, 'Australia', 'Australia'),
(1, 'Austria', 'Austria'),
(1, 'AVPU list', 'Lista AVDI'),
(1, 'AVPU scale', 'Escala A V D I'),
(1, 'Azerbaijan', 'Azerbaijan'),
(1, 'Azithromycin', 'Azitromicina'),
(1, 'Bacteraemia', 'Bacteremia'),
(1, 'Bahamas', 'Bahamas'),
(1, 'Bahrain', 'Bahrain'),
(1, 'Bangladesh', 'Bangladesh'),
(1, 'Barbados', 'Barbados'),
(1, 'Belarus', 'Belarus'),
(1, 'Belgium', 'Belgium'),
(1, 'Belize', 'Belize'),
(1, 'Benin', 'Benin'),
(1, 'Bermuda', 'Bermuda'),
(1, 'Better', 'Melhor'),
(1, 'Bhutan', 'Bhutan'),
(1, 'Bleeding', 'Sangramento (hemorragia)'),
(1, 'Bleeding (Haemorrhage)', 'Sangramento (hemorragia)'),
(1, 'Bolivia, Plurinational State of', 'Bolivia, Plurinational State of'),
(1, 'Boolean_Question', 'Questão booleana'),
(1, 'Bosnia and Herzegovina', 'Bosnia and Herzegovina'),
(1, 'Botswana', 'Botswana'),
(1, 'Bouvet Island', 'Bouvet Island'),
(1, 'BP (diastolic)', 'Pressão arterial (diastólica)'),
(1, 'BP (systolic)', 'Pressão arterial (sistólica)'),
(1, 'Brazil', 'Brazil'),
(1, 'British Indian Ocean Territory', 'British Indian Ocean Territory'),
(1, 'Bronchiolitis', 'Bronquiolite'),
(1, 'Brunei Darussalam', 'Brunei Darussalam'),
(1, 'Bulgaria', 'Bulgaria'),
(1, 'Burkina Faso', 'Burkina Faso'),
(1, 'Burundi', 'Burundi'),
(1, 'Cambodia', 'Cambodia'),
(1, 'Cameroon', 'Cameroon'),
(1, 'Canada', 'Canada'),
(1, 'Cape Verde', 'Cape Verde'),
(1, 'Cardiac arrest', 'Parada cardíaca'),
(1, 'Cardiac arrhythmia', 'Arritmia cardíaca'),
(1, 'Cardiomyopathy', 'Cardiomiopatia'),
(1, 'Cayman Islands', 'Cayman Islands'),
(1, 'Central African Republic', 'Central African Republic'),
(1, 'Chad', 'Chad'),
(1, 'Chest pain', 'Dor no peito'),
(1, 'Chest X-Ray /CT performed', 'Radiografia/tomografia computadorizada do tórax feita'),
(1, 'Chile', 'Chile'),
(1, 'China', 'China'),
(1, 'Chloroquine/hydroxychloroquine', 'Cloroquina / hidroxicloroquina'),
(1, 'Christmas Island', 'Christmas Island'),
(1, 'Chronic cardiac disease (not hypertension)', 'Doença cardíaca crônica (não hipertensão)'),
(1, 'Chronic kidney disease', 'Doença renal crônica'),
(1, 'Chronic liver disease', 'Doença hepática crônica'),
(1, 'Chronic neurological disorder', 'Doença neurológica crônica'),
(1, 'Chronic pulmonary disease', 'Doença pulmonar crônica'),
(1, 'Clinical inclusion criteria', 'Critérios Clínicos para Inclusão'),
(1, 'Clinical suspicion of ARI despite not meeting criteria above', 'Suspeita clínica de IRA apesar de não apresentar os sintomas acima'),
(1, 'Co-morbidities', 'Comorbidades'),
(1, 'Cocos (Keeling) Islands', 'Cocos (Keeling) Islands'),
(1, 'Colombia', 'Colombia'),
(1, 'Comoros', 'Comoros'),
(1, 'Complications', 'Complicações'),
(1, 'Concentrator', 'Concentrador'),
(1, 'Confusion', 'Confusão'),
(1, 'Congo', 'Congo'),
(1, 'Congo, the Democratic Republic of the', 'Congo, the Democratic Republic of the'),
(1, 'Conjunctivitis', 'Conjuntivite'),
(1, 'Cook Islands', 'Cook Islands'),
(1, 'Coronavirus', 'Coronavírus'),
(1, 'Coronavirus list', 'Lista Coronavirus'),
(1, 'Corticosteroid', 'Corticosteroide'),
(1, 'Corticosteroid list', 'Lista Corticosteroid'),
(1, 'Costa Rica', 'Costa Rica'),
(1, 'Cote d\'Ivoire', 'Cote d\'Ivoire'),
(1, 'Cough', 'Tosse'),
(1, 'Cough with haemoptysis', 'Tosse com hemóptise'),
(1, 'Cough with sputum', 'Tosse com expectoração'),
(1, 'Cough with sputum production', 'Tosse com expectoração'),
(1, 'Country', 'País'),
(1, 'Country list', 'Lista Paises'),
(1, 'CPAP/NIV mask', 'Máscara CPAP/VNI'),
(1, 'Creatine kinase measurement', 'Creatina quinase'),
(1, 'Creatinine measurement', 'Creatinina'),
(1, 'CRF section grouping questions about clinical inclusion criteria.', 'Parte do FRC que agrupa perguntas sobre os critérios clínicos para inclusão.'),
(1, 'Croatia', 'Croatia'),
(1, 'CRP measurement', 'PCR'),
(1, 'Cuba', 'Cuba'),
(1, 'Current smoking', 'Fumante'),
(1, 'Cylinder', 'Cilindro'),
(1, 'Cyprus', 'Cyprus'),
(1, 'Czech Republic', 'Czech Republic'),
(1, 'D-dimer measurement', 'Dimero D'),
(1, 'Daily clinical features', 'Sintomas diários'),
(1, 'Date of Birth', 'Data de nascimento'),
(1, 'Date of enrolment', 'Data de inscrição'),
(1, 'Date of follow up', 'Data do acompanhamento'),
(1, 'Date of ICU/HDU admission', 'Data de Admissão no CTI/UTI'),
(1, 'Date of onset and admission vital signs', 'Início da doença e sinais vitais na admissão'),
(1, 'Date question', 'Pergunta sobre data'),
(1, 'Death', 'Óbito'),
(1, 'Demographics', 'Dados demográficos'),
(1, 'Denmark', 'Denmark'),
(1, 'Diabetes', 'Diabete'),
(1, 'Diagnostic/pathogen testing', 'DIagnóstico/teste de patógenos'),
(1, 'Diarrhoea', 'Diarréia'),
(1, 'Discharge sub-section of the WHO COVID-19 CRF. This sub-section is provided when the patient is discharged from the health center or in the case of death.', 'Sub-seção de alta do FRC para o COVID-19 da OMS. Essa sub-seção é fornecida quando o paciente recebe alta do centro médica or em caso de óbito.'),
(1, 'Discharge/death form', 'Formulário de alta/óbito'),
(1, 'Discharged alive', 'Alta'),
(1, 'Djibouti', 'Djibouti'),
(1, 'Dominica', 'Dominica'),
(1, 'Dominican Republic', 'Dominican Republic'),
(1, 'duration in days', 'duração em dias'),
(1, 'duration in weeks', 'duração em semanas'),
(1, 'Dyspnoea (shortness of breath) OR Tachypnoea', 'Dispneia (falta de ar) ou Taquipneia'),
(1, 'e.g.BIPAP/CPAP', 'p.ex. BIPAP, CPAP'),
(1, 'Ecuador', 'Ecuador'),
(1, 'Egypt', 'Egypt'),
(1, 'El Salvador', 'El Salvador'),
(1, 'Endocarditis', 'Endocardite'),
(1, 'Equatorial Guinea', 'Equatorial Guinea'),
(1, 'Eritrea', 'Eritrea'),
(1, 'ESR measurement', 'VHS'),
(1, 'Estonia', 'Estonia'),
(1, 'Ethiopia', 'Ethiopia'),
(1, 'Existing conditions prior to admission.', 'Comorbidades existentes antes da admissão.'),
(1, 'Experimental agent', 'Agente experimental'),
(1, 'Extracorporeal (ECMO) support', 'Suporte extracorpóreo (ECMO)'),
(1, 'Facility name', 'Nome da Instalação'),
(1, 'Falciparum malaria', 'Malária Falciparum'),
(1, 'Falkland Islands (Malvinas)', 'Falkland Islands (Malvinas)'),
(1, 'Faroe Islands', 'Faroe Islands'),
(1, 'Fatigue/Malaise', 'Fadiga/mal estar'),
(1, 'Favipiravir', 'Favipiravir'),
(1, 'Female', 'Feminino'),
(1, 'Ferritin measurement', 'Ferritina'),
(1, 'Fiji', 'Fiji'),
(1, 'Finland', 'Finland'),
(1, 'FiO2 value', 'Fração de oxigênio inspirado'),
(1, 'first available data at presentation/admission', 'primeiros dados disponíveis na admissão'),
(1, 'Follow-up', 'Acompanhamento'),
(1, 'Follow-up sub-section of the WHO COVID-19 CRF. The completion frequency of this sub-section is determined by available resources.', 'Sub-seção do FRC para o COVID-19 da OMS. A frequência de preenchimento dessa sub-seção é determinada pelos recursos disponíveis.'),
(1, 'France', 'France'),
(1, 'French Guiana', 'French Guiana'),
(1, 'French Polynesia', 'French Polynesia'),
(1, 'French Southern Territories', 'French Southern Territories'),
(1, 'Gabon', 'Gabon'),
(1, 'Gambia', 'Gambia'),
(1, 'Georgia', 'Georgia'),
(1, 'Germany', 'Germany'),
(1, 'Gestational weeks assessment', 'Tempo de gravidez'),
(1, 'Ghana', 'Ghana'),
(1, 'Gibraltar', 'Gibraltar'),
(1, 'Glasgow Coma Score (GCS /15)', 'Escala de Coma de Glasgow (GCS /15)'),
(1, 'Greece', 'Greece'),
(1, 'Greenland', 'Greenland'),
(1, 'Grenada', 'Grenada'),
(1, 'Guadeloupe', 'Guadeloupe'),
(1, 'Guam', 'Guam'),
(1, 'Guatemala', 'Guatemala'),
(1, 'Guernsey', 'Guernsey'),
(1, 'Guinea', 'Guinea'),
(1, 'Guinea-Bissau', 'Guinea-Bissau'),
(1, 'Guyana', 'Guyana'),
(1, 'Haematocrit measurement', 'Hematócrito'),
(1, 'Haemoglobin measurement', 'Hemoglobina'),
(1, 'Haiti', 'Haiti'),
(1, 'Headache', 'Dor de cabeça'),
(1, 'Healthcare worker', 'Profissional de Saúde'),
(1, 'Heard Island and McDonald Islands', 'Heard Island and McDonald Islands'),
(1, 'Heart rate', 'Frequência cardíaca'),
(1, 'Height', 'Altura'),
(1, 'HF nasal cannula', 'Cânula nasal de alto fluxo'),
(1, 'History of fever', 'Histórico de febre'),
(1, 'HIV', 'HIV'),
(1, 'HIV list', 'Lista HIV'),
(1, 'Holy See (Vatican City State)', 'Holy See (Vatican City State)'),
(1, 'Honduras', 'Honduras'),
(1, 'Hong Kong', 'Hong Kong'),
(1, 'Hospitalized', 'Internado'),
(1, 'Hungary', 'Hungary'),
(1, 'Hypertension', 'Hipertensão'),
(1, 'Iceland', 'Iceland'),
(1, 'ICU or High Dependency Unit admission', 'UTI ou UCE'),
(1, 'ICU/HDU discharge date', 'Data de Alta do CTI/UTI'),
(1, 'If bleeding: specify site(s)', 'Caso afirmativo: especifique o(s) local(is)'),
(1, 'If yes, specify', 'Caso afirmativo, especifique'),
(1, 'IL-6 measurement', 'IL-6'),
(1, 'Inability to walk', 'Incapaz de andar'),
(1, 'India', 'India'),
(1, 'Indonesia', 'Indonesia'),
(1, 'Infiltrates present', 'Presença de infiltrados'),
(1, 'Influenza virus', 'Vírus influenza'),
(1, 'Influenza virus type', 'tipo de vírus influenza'),
(1, 'Inhaled', 'Inalatória'),
(1, 'Inotropes/vasopressors', 'Inotrópicos/vasopressores'),
(1, 'INR measurement', 'INR'),
(1, 'Interface list', 'Lista Interface de O2'),
(1, 'Interferon alpha', 'Interferon alfa'),
(1, 'Interferon beta', 'Interferon beta'),
(1, 'Intravenous', 'Intravenosa'),
(1, 'Intravenous fluids', 'Hidratação venosa'),
(1, 'Invasive ventilation', 'Ventilação invasiva'),
(1, 'Iran, Islamic Republic of', 'Iran, Islamic Republic of'),
(1, 'Iraq', 'Iraq'),
(1, 'Ireland', 'Ireland'),
(1, 'Is the patient CURRENTLY receiving any of the following?', 'O paciente esta recebendo algum dos seguintes ATUALMENTE?'),
(1, 'Isle of Man', 'Isle of Man'),
(1, 'Israel', 'Israel'),
(1, 'Italy', 'Italy'),
(1, 'Jamaica', 'Jamaica'),
(1, 'Japan', 'Japan'),
(1, 'Jersey', 'Jersey'),
(1, 'Joint pain (arthralgia)', 'Dor articular (artralgia)'),
(1, 'Jordan', 'Jordan'),
(1, 'Kazakhstan', 'Kazakhstan'),
(1, 'Kenya', 'Kenya'),
(1, 'Kiribati', 'Kiribati'),
(1, 'Korea, Democratic People\'s Republic of', 'Korea, Democratic People\'s Republic of'),
(1, 'Korea, Republic of', 'Korea, Republic of'),
(1, 'Kuwait', 'Kuwait'),
(1, 'Kyrgyzstan', 'Kyrgyzstan'),
(1, 'Laboratory question', 'Pergunta laboratorial'),
(1, 'Laboratory results', 'Resultados laboratoriais'),
(1, 'Laboratory Worker', 'Profissional de Laboratório'),
(1, 'Lactate measurement', 'Lactose'),
(1, 'Lao People\'s Democratic Republic', 'Lao People\'s Democratic Republic'),
(1, 'Latvia', 'Latvia'),
(1, 'LDH measurement', 'LDH'),
(1, 'Lebanon', 'Lebanon'),
(1, 'Lesotho', 'Lesotho'),
(1, 'Liberia', 'Liberia'),
(1, 'Libyan Arab Jamahiriya', 'Libyan Arab Jamahiriya'),
(1, 'Liechtenstein', 'Liechtenstein'),
(1, 'List of instances of the answers for the \'Sex at Birth\' question. In the WHO CRF, the three possible answers are: male, female or not specified.', 'Lista de instâncias das possíveis respostas para a pergunta \'Sexo as nascer\'. No FRC da OMS as três possíveis respostas são: masculino, feminino ou não especificado.'),
(1, 'List question', 'Questão com respostas em lista padronizada'),
(1, 'Lithuania', 'Lithuania'),
(1, 'Liver dysfunction', 'Disfunção hepática'),
(1, 'Lopinavir/Ritonavir', 'Lopinavir/Ritonavir'),
(1, 'Loss of smell', 'Perda do Olfato'),
(1, 'Loss of smell daily', 'Perda do Olfato'),
(1, 'Loss of smell signs', 'Perda do Olfato'),
(1, 'Loss of taste', 'Perda do paladar'),
(1, 'Loss of taste daily', 'Perda do paladar'),
(1, 'Loss of taste signs', 'Perda do paladar'),
(1, 'Lower chest wall indrawing', 'Retração toráxica'),
(1, 'Luxembourg', 'Luxembourg'),
(1, 'Lymphadenopathy', 'Linfadenopatia'),
(1, 'Macao', 'Macao'),
(1, 'Macedonia, the former Yugoslav Republic of', 'Macedonia, the former Yugoslav Republic of'),
(1, 'Madagascar', 'Madagascar'),
(1, 'Malawi', 'Malawi'),
(1, 'Malaysia', 'Malaysia'),
(1, 'Maldives', 'Maldives'),
(1, 'Male', 'Masculino'),
(1, 'Mali', 'Mali'),
(1, 'Malignant neoplasm', 'Neoplasma maligno'),
(1, 'Malnutrition', 'Desnutrição'),
(1, 'Malta', 'Malta'),
(1, 'Marshall Islands', 'Marshall Islands'),
(1, 'Martinique', 'Martinique'),
(1, 'Mask', 'Máscara'),
(1, 'Mask with reservoir', 'Máscara com reservatório'),
(1, 'Mauritania', 'Mauritania'),
(1, 'Mauritius', 'Mauritius'),
(1, 'Maximum daily corticosteroid dose', 'Dose diária máxima de corticosteroide'),
(1, 'Mayotte', 'Mayotte'),
(1, 'Medication', 'Medicação'),
(1, 'Meningitis/Encephalitis', 'Meningite/encefalite'),
(1, 'MERS-CoV', 'MERS-CoV'),
(1, 'Mexico', 'Mexico'),
(1, 'Micronesia, Federated States of', 'Micronesia, Federated States of'),
(1, 'Mid-upper arm circumference', 'Circunferência braquial'),
(1, 'Moldova, Republic of', 'Moldova, Republic of'),
(1, 'Monaco', 'Monaco'),
(1, 'Mongolia', 'Mongolia'),
(1, 'Montenegro', 'Montenegro'),
(1, 'Montserrat', 'Montserrat'),
(1, 'Morocco', 'Morocco'),
(1, 'Mozambique', 'Mozambique'),
(1, 'Muscle aches (myalgia)', 'Dor muscular (mialgia)'),
(1, 'Myanmar', 'Myanmar'),
(1, 'Myocarditis/Pericarditis', 'Miocardite/Pericardite'),
(1, 'N/A', 'Não informado'),
(1, 'Namibia', 'Namibia'),
(1, 'Nauru', 'Nauru'),
(1, 'Negative', 'Negativo'),
(1, 'Nepal', 'Nepal'),
(1, 'Netherlands', 'Netherlands'),
(1, 'Netherlands Antilles', 'Netherlands Antilles'),
(1, 'Neuraminidase inhibitor', 'Inibidor de neuraminidase'),
(1, 'New Caledonia', 'New Caledonia'),
(1, 'New Zealand', 'New Zealand'),
(1, 'Nicaragua', 'Nicaragua'),
(1, 'Niger', 'Niger'),
(1, 'Nigeria', 'Nigeria'),
(1, 'Niue', 'Niue'),
(1, 'No', 'Não'),
(1, 'Non-Falciparum malaria', 'Malária Não Falciparum'),
(1, 'Non-invasive ventilation', 'Ventilação não-invasiva'),
(1, 'Non-steroidal anti-inflammatory (NSAID)', 'Antiinflamatório não esteroide (AINE)'),
(1, 'Norfolk Island', 'Norfolk Island'),
(1, 'Northern Mariana Islands', 'Northern Mariana Islands'),
(1, 'Norway', 'Norway'),
(1, 'Not done', 'Não realizado'),
(1, 'Not known, not observed, not recorded, or refused.', 'Desconhecido, não observado, não registrato or recusado.'),
(1, 'Not Specified', 'Não especificado'),
(1, 'Number question', 'Pergunta numérica'),
(1, 'O2 flow', 'Vazão de O2'),
(1, 'O2 flow list', 'Lista fluxo de O2'),
(1, 'Oman', 'Oman'),
(1, 'Oral', 'Oral'),
(1, 'Oral/orogastric fluids', 'Hidratação oral/orogástrica'),
(1, 'Other co-morbidities', 'Outras comorbidades'),
(1, 'Other complication', 'Outra complicação'),
(1, 'Other corona virus', 'Outro coronavírus'),
(1, 'Other respiratory pathogen', 'Outro patógeno respiratório'),
(1, 'Other signs or symptoms', 'Outros'),
(1, 'Outcome', 'Desfecho'),
(1, 'Outcome date', 'Data do desfecho'),
(1, 'Outcome list', 'Lista de desfecho'),
(1, 'Outcome saturation list', 'Lista de Saturação de desfecho'),
(1, 'Oxygen interface', 'Interface de oxigenoterapia'),
(1, 'Oxygen saturation', 'Saturação de oxigênio'),
(1, 'Oxygen saturation expl', 'em'),
(1, 'Oxygen therapy', 'Oxigenoterapia'),
(1, 'PaCO2 value', 'Pressão parcial do CO2'),
(1, 'Pain', 'Dor'),
(1, 'Pakistan', 'Pakistan'),
(1, 'Palau', 'Palau'),
(1, 'Palestinian Territory, Occupied', 'Palestinian Territory, Occupied'),
(1, 'Palliative discharge', 'Alta paliativa'),
(1, 'Panama', 'Panama'),
(1, 'Pancreatitis', 'Pancreatite'),
(1, 'PaO2 value', 'Pressão parcial do O2'),
(1, 'Papua New Guinea', 'Papua New Guinea'),
(1, 'Paraguay', 'Paraguay'),
(1, 'PEEP value', 'Pressão expiratória final positiva'),
(1, 'Peru', 'Peru'),
(1, 'Philippines', 'Philippines'),
(1, 'Piped', 'Canalizado'),
(1, 'Pitcairn', 'Pitcairn'),
(1, 'Plateau pressure value', 'Pressão do plato'),
(1, 'Platelets measurement', 'Plaquetas'),
(1, 'Pneumonia', 'Pneumonia'),
(1, 'PNNot_done_Question', 'Questão com resposta Positivo Negativo ou não realizada'),
(1, 'pnnotdone_list', 'Lista PNNotDone'),
(1, 'Poland', 'Poland'),
(1, 'Portugal', 'Portugal'),
(1, 'Positive', 'Positivo'),
(1, 'Potassium measurement', 'Potássio'),
(1, 'Pre-admission & chronic medication', 'Pré-admissão e medicamentos de uso contínuo'),
(1, 'Pregnant', 'Grávida'),
(1, 'Procalcitonin measurement', 'Procalcitonina'),
(1, 'Prone position', 'Posição prona'),
(1, 'Proven or suspected infection with pathogen of Public Health Interest', 'Quadro de infecção comprovada ou suspeita com patógeno de interesse para a Saúde Pública'),
(1, 'PT measurement', 'TP'),
(1, 'Puerto Rico', 'Puerto Rico'),
(1, 'Qatar', 'Qatar'),
(1, 'Renal replacement therapy (RRT) or dialysis', 'Terapia de substituição renal ou diálise'),
(1, 'Respiratory rate', 'Frequência respiratória'),
(1, 'Reunion ﻿ Réunion', 'Reunion ﻿ Réunion'),
(1, 'Ribavirin', 'Ribavirina'),
(1, 'Romania', 'Romania'),
(1, 'Room air', 'ar ambiente'),
(1, 'Runny nose (rhinorrhoea)', 'Coriza (rinorréia)'),
(1, 'Russian Federation', 'Russian Federation'),
(1, 'Rwanda', 'Rwanda'),
(1, 'Saint Barthélemy', 'Saint Barthélemy'),
(1, 'Saint Helena', 'Saint Helena'),
(1, 'Saint Kitts and Nevis', 'Saint Kitts and Nevis'),
(1, 'Saint Lucia', 'Saint Lucia'),
(1, 'Saint Martin (French part)', 'Saint Martin (French part)'),
(1, 'Saint Pierre and Miquelon', 'Saint Pierre and Miquelon'),
(1, 'Saint Vincent and the Grenadines', 'Saint Vincent and the Grenadines'),
(1, 'Same as before illness', 'Como antes da doença'),
(1, 'Samoa', 'Samoa'),
(1, 'San Marino', 'San Marino'),
(1, 'Sao Tome and Principe', 'Sao Tome and Principe'),
(1, 'SARS-CoV-2', 'SARS-CoV-2'),
(1, 'Saudi Arabia', 'Saudi Arabia'),
(1, 'Seizures', 'Convulsões'),
(1, 'self_care_list', 'Lista cuidados'),
(1, 'Senegal', 'Senegal'),
(1, 'Serbia', 'Serbia'),
(1, 'Severe dehydration', 'Desidratação severa'),
(1, 'Sex at Birth', 'Sexo ao Nascer'),
(1, 'sex at birth list', 'Lista de sexo'),
(1, 'Seychelles', 'Seychelles'),
(1, 'Shock', 'Choque'),
(1, 'Shortness of breath', 'Falta de ar'),
(1, 'Sierra Leone', 'Sierra Leone'),
(1, 'Signs and symptoms on admission', 'Sinais e sintomas na hora da admissão'),
(1, 'Singapore', 'Singapore'),
(1, 'Site name', 'Localidade'),
(1, 'Skin rash', 'Erupções cutâneas'),
(1, 'Skin ulcers', 'Úlceras cutâneas'),
(1, 'Slovakia', 'Slovakia'),
(1, 'Slovenia', 'Slovenia'),
(1, 'Sodium measurement', 'Sódio'),
(1, 'Solomon Islands', 'Solomon Islands'),
(1, 'Somalia', 'Somalia'),
(1, 'Sore throat', 'Dor de garganta'),
(1, 'Source of oxygen', 'Fonte de Oxigênio'),
(1, 'Source of oxygen list', 'lista de fonte de O2'),
(1, 'South Africa', 'South Africa'),
(1, 'South Georgia and the South Sandwich Islands', 'South Georgia and the South Sandwich Islands'),
(1, 'Spain', 'Spain'),
(1, 'specific response', 'resposta específica'),
(1, 'Sri Lanka', 'Sri Lanka'),
(1, 'Sternal capillary refill time >2seconds', 'Tempo de enchimento capilar >2 segundos'),
(1, 'Sudan', 'Sudan'),
(1, 'Supportive care', 'Cuidados'),
(1, 'Suriname', 'Suriname'),
(1, 'Svalbard and Jan Mayen', 'Svalbard and Jan Mayen'),
(1, 'Swaziland', 'Swaziland'),
(1, 'Sweden', 'Sweden'),
(1, 'Switzerland', 'Switzerland'),
(1, 'Symptom onset (date of first/earliest symptom)', 'Início de Sintomas (data do primeiro sintoma)'),
(1, 'Syrian Arab Republic', 'Syrian Arab Republic'),
(1, 'Systemic anticoagulation', 'Anticoagulação sistêmica'),
(1, 'Taiwan, Province of China', 'Taiwan, Province of China'),
(1, 'Tajikistan', 'Tajikistan'),
(1, 'Tanzania, United Republic of', 'Tanzania, United Republic of'),
(1, 'Temperature', 'Temperatura'),
(1, 'Text_Question', 'Questão com resposta textual'),
(1, 'Thailand', 'Thailand'),
(1, 'The affirmative response to a question.', 'A resposta afirmativa à uma pergunta.'),
(1, 'The country where the medical center is located.', 'O país onde o centro médico está localizado.'),
(1, 'The identifier of the person as a participant (the subject) of the reported case. According to WHO, this identifier should be a combination of the site code (the unique code of the health center) and the participant number (generated by the health center). Health center can obtain the site code and ', 'O identificador da pessoa enquanto participante (o objeto) do case relatado pelo FRC. De acordo com a OMS, esse identificador deve ser criado a partir da junção do código da localidade (o código único do centro médico) e do número do participante (gerado pelo centro médico). Centros médicos podem obter o código da localidade e se registrarem no sistema de gestão de dados da OMS contatando edcarn@who.int.'),
(1, 'The name of the health center in which the participant is being treated.', 'O centro médico onde o participante está sendo tratado.'),
(1, 'The non-affirmative response to a question.', 'A resposta negativa à uma pergunta.'),
(1, 'The number of breaths (inhalation and exhalation) taken per minute time.', 'O número de respirações medidos a cada minuto.'),
(1, 'The number of heartbeats measured per minute time.', 'O número de batimentos cardíacos medidos a cada minuto.'),
(1, 'The Person that is the case subject of the WHO CRF.', 'A Pessoa que é o objeto do caso relatado pelo FRC da OMS.'),
(1, 'This class represents the Rapid version of the World Health Organisation\'s (WHO) Case Record Form (CRF) for the COVID-19 outbreak.', 'Esta classe representa a versão Rapid do Formulário de Relato de Caso (FRC) para a epidemia COVID-19, criada pela Organização Mundial de Saúde.'),
(1, 'time in weeks', 'tempo em semanas'),
(1, 'Timor-Leste', 'Timor-Leste'),
(1, 'Togo', 'Togo'),
(1, 'Tokelau', 'Tokelau'),
(1, 'Tonga', 'Tonga'),
(1, 'Total bilirubin measurement', 'Bilirrubina total'),
(1, 'Total duration ECMO', 'duração em dias'),
(1, 'Total duration ICU/HCU', 'duração em dias'),
(1, 'Total duration Inotropes/vasopressors', 'duração em dias'),
(1, 'Total duration Invasive ventilation', 'duração em dias'),
(1, 'Total duration Non-invasive ventilation', 'duração em dias'),
(1, 'Total duration Oxygen Therapy', 'duração em dias'),
(1, 'Total duration Prone position', 'duração em dias'),
(1, 'Total duration RRT or dyalysis', 'duração em dias'),
(1, 'Transfer to other facility', 'Transferência para outra unidade'),
(1, 'Trinidad and Tobago', 'Trinidad and Tobago'),
(1, 'Troponin measurement', 'Troponina'),
(1, 'Tuberculosis', 'Tuberculose'),
(1, 'Tunisia', 'Tunisia'),
(1, 'Turkey', 'Turkey'),
(1, 'Turkmenistan', 'Turkmenistan'),
(1, 'Turks and Caicos Islands', 'Turks and Caicos Islands'),
(1, 'Tuvalu', 'Tuvalu'),
(1, 'Uganda', 'Uganda'),
(1, 'Ukraine', 'Ukraine'),
(1, 'United Arab Emirates', 'United Arab Emirates'),
(1, 'United Kingdom', 'United Kingdom'),
(1, 'United States', 'United States'),
(1, 'United States Minor Outlying Islands', 'United States Minor Outlying Islands'),
(1, 'Unknown', 'Desconhecido'),
(1, 'Unresponsive', 'Indiferente'),
(1, 'Urea (BUN) measurement', 'Uréia (BUN)'),
(1, 'Uruguay', 'Uruguay'),
(1, 'Uzbekistan', 'Uzbekistan'),
(1, 'Vanuatu', 'Vanuatu'),
(1, 'Venezuela, Bolivarian Republic of', 'Venezuela, Bolivarian Republic of'),
(1, 'Ventilation question', 'Questão sobre Ventilação'),
(1, 'Verbal', 'Verbal'),
(1, 'Viet Nam', 'Viet Nam'),
(1, 'Viral haemorrhagic fever', 'Febre viral hemorrágica'),
(1, 'Virgin Islands, British', 'Virgin Islands, British'),
(1, 'Virgin Islands, U.S.', 'Virgin Islands, U.S.'),
(1, 'Vital signs', 'Sinais Vitais'),
(1, 'Vomiting/Nausea', 'Vômito/náusea'),
(1, 'Wallis and Futuna', 'Wallis and Futuna'),
(1, 'Was pathogen testing done during this illness episode', 'Esse teste foi realizado durante este episódio da doença'),
(1, 'WBC count measurement', 'Leucócitos'),
(1, 'Weight', 'Peso'),
(1, 'Were any of the following taken within 14 days of admission?', 'Marque os usados nos 14 dias antes da admissão'),
(1, 'Western Sahara', 'Western Sahara'),
(1, 'Wheezing', 'Respiração sibilante'),
(1, 'Which antibiotic', 'Antibiótico'),
(1, 'Which antifungal agent', 'Qual agente antifungal'),
(1, 'Which antimalarial agent', 'Qual agente antimalárico'),
(1, 'Which antiviral', 'Qual antiviral'),
(1, 'Which complication', 'Qual complicação'),
(1, 'Which coronavirus', 'Qual coronavírus'),
(1, 'Which corticosteroid route', 'Qual via do corticosteroide'),
(1, 'Which experimental agent', 'Qual agente experimental'),
(1, 'Which NSAID', 'Qual AINE'),
(1, 'Which other antiviral', 'Qual outro antiviral'),
(1, 'Which other co-morbidities', 'Outras comorbidades'),
(1, 'Which other pathogen of public health interest detected', 'Qual outro patógeno'),
(1, 'Which respiratory pathogen', 'Qual patógeno respiratório'),
(1, 'Which sign or symptom', 'Qual sinal ou sintoma'),
(1, 'Which virus', 'Qual vírus'),
(1, 'WHO COVID-19 Rapid Version CRF', 'OMS-COVID-19-Rapid-FRC'),
(1, 'Worse', 'Pior'),
(1, 'Yemen', 'Yemen'),
(1, 'Yes', 'Sim'),
(1, 'Yes-not on ART', 'Sim-não toma antivirais'),
(1, 'Yes-on ART', 'Sim-toma antivirais'),
(1, 'ynu_list', 'Lista YNU'),
(1, 'YNU_Question', 'Questão com resposta Sim Não Desconhecido'),
(1, 'ynun_list', 'Lista YNUN'),
(1, 'YNUN_Question', 'Questão com resposta Sim Não Desconhecido Não Informado'),
(1, 'Zambia', 'Zambia'),
(1, 'Zimbabwe', 'Zimbabwe'),
(1, 'Published', 'Publicado'),
(1, 'Deprecated', 'Deprecado'),
(1, 'New', 'Novo');

-- --------------------------------------------------------

--
-- Table structure for table `tb_notificationrecord`
--

CREATE TABLE `tb_notificationrecord` (
  `userID` int(11) NOT NULL,
  `profileID` int(11) NOT NULL,
  `hospitalUnitID` int(11) NOT NULL,
  `tableName` varchar(255) NOT NULL,
  `rowdID` int(11) NOT NULL,
  `changedOn` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `operation` varchar(1) NOT NULL,
  `log` text DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_notificationrecord`
--

INSERT INTO `tb_notificationrecord` (`userID`, `profileID`, `hospitalUnitID`, `tableName`, `rowdID`, `changedOn`, `operation`, `log`) VALUES
(3, 7, 1, 'tb_participant', 168, '2020-12-08 15:19:34', 'I', 'Inclusão de paciente: 808080808081'),
(3, 7, 1, 'tb_participant', 169, '2020-12-08 15:22:27', 'I', 'Inclusão de paciente: 808080808082'),
(3, 7, 1, 'tb_assessmentquestionnaire', 0, '2020-12-08 15:22:27', 'I', 'Inclusão do registro referente ao paciente: 169 para o hospital: 1'),
(3, 7, 1, 'tb_formRecord', 238, '2020-12-08 15:29:18', 'I', 'Inclusão de Modulo para paciente: 168'),
(3, 7, 1, 'tb_questiongroupformrecord', 1129, '2020-12-08 15:29:18', 'I', 'Inclusão da questão referente a data do Modulo para paciente: 168'),
(3, 1, 1, 'tb_user', 8, '2020-12-09 18:43:06', 'I', 'Inclusão de dados do Usuario: Admin HUGG'),
(8, 1, 1, 'tb_userrole', 0, '2020-12-09 18:57:22', 'A', 'Suspenso acesso do usuário5 ao hospital Hospital Universitário Gaffrée e Guinle - HUGG'),
(8, 1, 1, 'tb_userrole', 0, '2020-12-09 18:57:42', 'A', 'Retorno de acesso do usuário5 ao hospital Hospital Universitário Gaffrée e Guinle - HUGG'),
(8, 1, 1, 'tb_user', 9, '2020-12-09 19:05:04', 'I', 'Inclusão de dados do Usuario: Teste5'),
(3, 7, 1, 'tb_participant', 0, '2020-12-21 15:22:39', 'A', 'Alteração de  Prontuario de: 100011583533 para 100011589999'),
(3, 7, 1, 'tb_participant', 0, '2020-12-21 15:27:30', 'A', 'Alteração do paciente 0 - Prontuario de: 100011589999 para 100011583533'),
(3, 7, 1, 'tb_participant', 0, '2020-12-21 15:29:35', 'A', 'Alteração - Prontuario de: 100011583533 para 100011589999'),
(3, 7, 1, 'tb_participant', 0, '2020-12-21 15:29:47', 'A', 'Alteração - Prontuario de: 100011589999 para 100011583533'),
(3, 7, 1, 'tb_participant', 88, '2020-12-21 15:31:25', 'A', 'Alteração - Prontuario de: 100011583533 para 100011589999'),
(3, 7, 1, 'tb_participant', 88, '2020-12-21 15:31:46', 'A', 'Alteração - Prontuario de: 100011589999 para 100011583533'),
(3, 7, 1, 'tb_participant', 170, '2020-12-22 12:37:45', 'I', 'Inclusão de paciente: 808080808888'),
(3, 7, 1, 'tb_assessmentquestionnaire', 0, '2020-12-22 12:37:45', 'I', 'Inclusão do registro referente ao paciente: 170 para o hospital: 1'),
(3, 7, 1, 'tb_participant', 171, '2020-12-22 12:55:21', 'I', 'Inclusão de paciente: 808080808889'),
(3, 7, 1, 'tb_assessmentquestionnaire', 0, '2020-12-22 12:55:21', 'I', 'Inclusão do registro referente ao paciente: 171 para o hospital: 1'),
(3, 7, 1, 'tb_participant', 171, '2020-12-22 13:12:22', 'A', 'Alteração - Prontuario de: 808080808889 para 808080808890'),
(3, 7, 1, 'tb_participant', 171, '2020-12-22 13:12:44', 'A', 'Alteração - Prontuario de: 808080808890 para 808080808889'),
(3, 7, 1, 'tb_participant', 172, '2020-12-22 14:05:49', 'I', 'Inclusão de paciente: 808080808891'),
(3, 7, 1, 'tb_assessmentquestionnaire', 0, '2020-12-22 14:05:49', 'I', 'Inclusão do registro referente ao paciente: 172 para o hospital: 1'),
(11, 1, 1, 'tb_participant', 173, '2021-01-25 15:03:48', 'I', 'Inclusão de paciente: 123456'),
(11, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-01-25 15:03:48', 'I', 'Inclusão do registro referente ao paciente: 173 para o hospital: 1'),
(11, 1, 1, 'tb_participant', 174, '2021-01-25 15:07:47', 'I', 'Inclusão de paciente: 1234567'),
(11, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-01-25 15:07:47', 'I', 'Inclusão do registro referente ao paciente: 174 para o hospital: 1'),
(11, 1, 1, 'tb_participant', 175, '2021-01-25 15:08:43', 'I', 'Inclusão de paciente: 12345678'),
(11, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-01-25 15:08:43', 'I', 'Inclusão do registro referente ao paciente: 175 para o hospital: 1'),
(11, 1, 1, 'tb_participant', 176, '2021-01-25 15:13:43', 'I', 'Inclusão de paciente: 123456789'),
(11, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-01-25 15:13:43', 'I', 'Inclusão do registro referente ao paciente: 176 para o hospital: 1'),
(11, 1, 1, 'tb_participant', 177, '2021-01-25 15:17:34', 'I', 'Inclusão de paciente: 1234567890'),
(11, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-01-25 15:17:34', 'I', 'Inclusão do registro referente ao paciente: 177 para o hospital: 1'),
(11, 1, 2, 'tb_participant', 178, '2021-01-25 15:18:35', 'I', 'Inclusão de paciente: 1234567'),
(11, 1, 2, 'tb_assessmentquestionnaire', 0, '2021-01-25 15:18:35', 'I', 'Inclusão do registro referente ao paciente: 178 para o hospital: 2'),
(11, 1, 1, 'tb_participant', 179, '2021-01-25 15:20:40', 'I', 'Inclusão de paciente: 111'),
(11, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-01-25 15:20:40', 'I', 'Inclusão do registro referente ao paciente: 179 para o hospital: 1'),
(11, 1, 1, 'tb_formRecord', 239, '2021-01-26 19:55:52', 'I', 'Inclusão de Modulo para paciente: 88'),
(11, 1, 1, 'tb_questiongroupformrecord', 1130, '2021-01-26 19:55:52', 'I', 'Inclusão de Resposta da 117:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1131, '2021-01-26 19:55:52', 'I', 'Inclusão de Resposta da 120:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1132, '2021-01-26 19:55:52', 'I', 'Inclusão de Resposta da 150:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1133, '2021-01-26 19:55:52', 'I', 'Inclusão de Resposta da 154:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1134, '2021-01-26 19:55:52', 'I', 'Inclusão de Resposta da 168:2021-01-19'),
(11, 1, 1, 'tb_questiongroupformrecord', 1135, '2021-01-26 19:55:52', 'I', 'Inclusão de Resposta da 217:36'),
(11, 1, 1, 'tb_formRecord', 240, '2021-01-26 20:00:54', 'I', 'Inclusão de Modulo para paciente: 88'),
(11, 1, 1, 'tb_questiongroupformrecord', 1136, '2021-01-26 20:00:54', 'I', 'Inclusão de Resposta da 33:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1137, '2021-01-26 20:00:54', 'I', 'Inclusão de Resposta da 39:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1138, '2021-01-26 20:00:54', 'I', 'Inclusão de Resposta da 152:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1139, '2021-01-26 20:00:54', 'I', 'Inclusão de Resposta da 168:2020-04-22'),
(11, 1, 1, 'tb_questiongroupformrecord', 1140, '2021-01-26 20:00:54', 'I', 'Inclusão de Resposta da 183:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1141, '2021-01-26 20:00:54', 'I', 'Inclusão de Resposta da 197:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1142, '2021-01-26 20:00:54', 'I', 'Inclusão de Resposta da 199:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1143, '2021-01-26 20:00:54', 'I', 'Inclusão de Resposta da 216:Verbal - 2:9'),
(11, 1, 1, 'tb_formRecord', 241, '2021-01-26 20:19:55', 'I', 'Inclusão de Modulo para paciente: 88'),
(11, 1, 1, 'tb_questiongroupformrecord', 1144, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 83:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1145, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 119:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1146, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 156:123'),
(11, 1, 1, 'tb_questiongroupformrecord', 1147, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 168:2020-04-30'),
(11, 1, 1, 'tb_questiongroupformrecord', 1148, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 177:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1149, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 183:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1150, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 184:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1151, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 185:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1152, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 218:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1153, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 220:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1154, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 241:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1155, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 250:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1156, '2021-01-26 20:19:55', 'I', 'Inclusão de Resposta da 251:Não - 15:296'),
(11, 1, 1, 'tb_formRecord', 242, '2021-02-02 15:07:45', 'I', 'Inclusão de Modulo para paciente: 88'),
(11, 1, 1, 'tb_questiongroupformrecord', 1157, '2021-02-02 15:07:45', 'I', 'Inclusão de Resposta da 35:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1158, '2021-02-02 15:07:45', 'I', 'Inclusão de Resposta da 36:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1159, '2021-02-02 15:07:45', 'I', 'Inclusão de Resposta da 119:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1160, '2021-02-02 15:07:45', 'I', 'Inclusão de Resposta da 155:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1161, '2021-02-02 15:07:45', 'I', 'Inclusão de Resposta da 168:2021-02-03'),
(11, 1, 1, 'tb_formRecord', 243, '2021-02-02 15:10:41', 'I', 'Inclusão de Modulo para paciente: 88'),
(11, 1, 1, 'tb_questiongroupformrecord', 1162, '2021-02-02 15:10:41', 'I', 'Inclusão de Resposta da 168:2021-02-04'),
(11, 1, 1, 'tb_formRecord', 244, '2021-02-02 15:13:37', 'I', 'Inclusão de Modulo para paciente: 88'),
(11, 1, 1, 'tb_questiongroupformrecord', 1163, '2021-02-02 15:13:38', 'I', 'Inclusão de Resposta da 166:Brazil - 5:45'),
(11, 1, 1, 'tb_questiongroupformrecord', 1164, '2021-02-02 15:13:38', 'I', 'Inclusão de Resposta da 167:2021-02-15'),
(11, 1, 1, 'tb_questiongroupformrecord', 1165, '2021-02-02 15:13:38', 'I', 'Inclusão de Resposta da 242:HUGG'),
(11, 1, 1, 'tb_questiongroupformrecord', 1166, '2021-02-02 15:32:56', 'I', 'Inclusão de Resposta da 83:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1166, '2021-02-02 15:32:56', 'A', 'Exclusão da Resposta: 2020-04-30 para Inclusão de Resposta da 177:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1166, '2021-02-02 15:38:41', 'A', 'Exclusão da Resposta: 297 para Inclusão de Resposta da 83:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 10, '2021-02-02 15:43:52', 'A', 'Exclusão da Resposta: 300 para Inclusão de Resposta da 150:Não - 15:296'),
(3, 7, 1, 'tb_questiongroupformrecord', 1166, '2021-02-02 16:32:26', 'A', 'Exclusão da Resposta: 296 para Inclusão de Resposta da 83:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1167, '2021-02-02 16:46:06', 'I', 'Inclusão de Resposta da 47:false'),
(11, 1, 1, 'tb_questiongroupformrecord', 1168, '2021-02-02 16:46:06', 'I', 'Inclusão de Resposta da 49:true'),
(11, 1, 1, 'tb_questiongroupformrecord', 1169, '2021-02-02 16:46:53', 'I', 'Inclusão de Resposta da 31:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1170, '2021-02-02 16:46:53', 'I', 'Inclusão de Resposta da 32:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1171, '2021-02-02 18:36:21', 'I', 'Inclusão de Resposta da 155:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1172, '2021-02-02 18:36:21', 'I', 'Inclusão de Resposta da 217:37'),
(11, 1, 1, 'tb_participant', 180, '2021-02-05 20:53:11', 'I', 'Inclusão de paciente: 9876543210'),
(11, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-02-05 20:53:11', 'I', 'Inclusão do registro referente ao paciente: 180 para o hospital: 1'),
(11, 1, 1, 'tb_user', 12, '2021-02-08 18:07:18', 'I', 'Inclusão de dados do Usuario: teste@teste.com'),
(11, 1, 1, 'tb_user', 13, '2021-02-08 18:10:27', 'I', 'Inclusão de dados do Usuario: teste11@email.com'),
(11, 1, 1, 'tb_user', 14, '2021-02-08 18:13:05', 'I', 'Inclusão de dados do Usuario: user@email.com'),
(14, 7, 1, 'tb_questiongroupformrecord', 1173, '2021-02-08 18:41:50', 'I', 'Inclusão de Resposta da 177:Sim - 15:298'),
(14, 7, 1, 'tb_questiongroupformrecord', 1174, '2021-02-08 18:41:50', 'I', 'Inclusão de Resposta da 183:Não - 15:296'),
(14, 7, 1, 'tb_questiongroupformrecord', 1175, '2021-02-08 18:41:50', 'I', 'Inclusão de Resposta da 185:Sim - 15:298'),
(14, 7, 1, 'tb_questiongroupformrecord', 1176, '2021-02-08 18:41:50', 'I', 'Inclusão de Resposta da 197:Não - 15:296'),
(14, 7, 1, 'tb_questiongroupformrecord', 1177, '2021-02-08 18:41:50', 'I', 'Inclusão de Resposta da 217:37'),
(11, 1, 1, 'tb_questiongroupformrecord', 1178, '2021-02-08 18:42:56', 'I', 'Inclusão de Resposta da 47:true'),
(11, 1, 1, 'tb_questiongroupformrecord', 1179, '2021-02-08 18:42:56', 'I', 'Inclusão de Resposta da 49:true'),
(11, 1, 1, 'tb_questiongroupformrecord', 1180, '2021-02-08 18:42:56', 'I', 'Inclusão de Resposta da 64:false'),
(11, 1, 1, 'tb_questiongroupformrecord', 1181, '2021-02-08 18:43:40', 'I', 'Inclusão de Resposta da 149:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1182, '2021-02-08 18:43:40', 'I', 'Inclusão de Resposta da 151:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1183, '2021-02-08 18:43:40', 'I', 'Inclusão de Resposta da 153:Desconhecido - 16:301'),
(11, 1, 1, 'tb_questiongroupformrecord', 1184, '2021-02-08 18:43:40', 'I', 'Inclusão de Resposta da 154:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1185, '2021-02-08 18:43:40', 'I', 'Inclusão de Resposta da 218:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1186, '2021-02-08 18:43:40', 'I', 'Inclusão de Resposta da 220:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1187, '2021-02-08 18:46:51', 'I', 'Inclusão de Resposta da 54:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1188, '2021-02-08 18:46:51', 'I', 'Inclusão de Resposta da 55:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1189, '2021-02-08 18:46:51', 'I', 'Inclusão de Resposta da 59:Desconhecido - 6:262'),
(11, 1, 1, 'tb_questiongroupformrecord', 1190, '2021-02-08 18:46:51', 'I', 'Inclusão de Resposta da 63:true'),
(11, 1, 1, 'tb_questiongroupformrecord', 1191, '2021-02-08 18:46:51', 'I', 'Inclusão de Resposta da 64:true'),
(11, 1, 1, 'tb_user', 15, '2021-02-08 19:39:51', 'I', 'Inclusão de dados do Usuario: rodrigo@gmail.com'),
(15, 6, 1, 'tb_questiongroupformrecord', 1192, '2021-02-08 19:41:40', 'I', 'Inclusão de Resposta da 47:false'),
(15, 6, 1, 'tb_questiongroupformrecord', 1193, '2021-02-08 19:41:40', 'I', 'Inclusão de Resposta da 48:false'),
(15, 6, 1, 'tb_questiongroupformrecord', 1194, '2021-02-08 19:41:40', 'I', 'Inclusão de Resposta da 49:false'),
(15, 6, 1, 'tb_questiongroupformrecord', 1195, '2021-02-08 19:41:40', 'I', 'Inclusão de Resposta da 63:false'),
(15, 6, 1, 'tb_questiongroupformrecord', 1196, '2021-02-08 19:41:40', 'I', 'Inclusão de Resposta da 64:true'),
(15, 6, 1, 'tb_formRecord', 245, '2021-02-08 19:42:29', 'I', 'Inclusão de Modulo para paciente: 95'),
(15, 6, 1, 'tb_questiongroupformrecord', 1197, '2021-02-08 19:42:29', 'I', 'Inclusão de Resposta da 168:2020-04-25'),
(15, 6, 1, 'tb_questiongroupformrecord', 1198, '2021-02-08 19:42:29', 'I', 'Inclusão de Resposta da 217:37'),
(15, 6, 1, 'tb_questiongroupformrecord', 1199, '2021-02-08 19:42:29', 'I', 'Inclusão de Resposta da 218:Não - 15:296'),
(15, 6, 1, 'tb_questiongroupformrecord', 1200, '2021-02-08 19:42:29', 'I', 'Inclusão de Resposta da 220:Não - 15:296'),
(15, 6, 1, 'tb_participant', 181, '2021-02-08 19:42:55', 'I', 'Inclusão de paciente: 10001000'),
(15, 6, 1, 'tb_assessmentquestionnaire', 0, '2021-02-08 19:42:55', 'I', 'Inclusão do registro referente ao paciente: 181 para o hospital: 1'),
(11, 1, 1, 'tb_participant', 182, '2021-02-08 19:54:08', 'I', 'Inclusão de paciente: 12345678910'),
(11, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-02-08 19:54:08', 'I', 'Inclusão do registro referente ao paciente: 182 para o hospital: 1'),
(15, 6, 1, 'tb_questiongroupformrecord', 1201, '2021-02-08 19:55:44', 'I', 'Inclusão de Resposta da 203:Não - 15:296'),
(15, 6, 1, 'tb_questiongroupformrecord', 1202, '2021-02-08 19:55:44', 'I', 'Inclusão de Resposta da 204:Sim - 15:298'),
(11, 1, 1, 'tb_formRecord', 246, '2021-02-23 21:25:47', 'I', 'Inclusão de Modulo para paciente: 181'),
(11, 1, 1, 'tb_questiongroupformrecord', 1203, '2021-02-23 21:25:47', 'I', 'Inclusão de Resposta da 49:true'),
(11, 1, 1, 'tb_questiongroupformrecord', 1204, '2021-02-23 21:25:47', 'I', 'Inclusão de Resposta da 51:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1205, '2021-02-23 21:25:47', 'I', 'Inclusão de Resposta da 61:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1206, '2021-02-23 21:25:47', 'I', 'Inclusão de Resposta da 62:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1207, '2021-02-23 21:25:47', 'I', 'Inclusão de Resposta da 167:2021-02-22'),
(11, 1, 1, 'tb_questiongroupformrecord', 1208, '2021-02-23 21:25:47', 'I', 'Inclusão de Resposta da 202:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1209, '2021-02-23 21:25:47', 'I', 'Inclusão de Resposta da 203:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1210, '2021-02-23 21:27:32', 'I', 'Inclusão de Resposta da 129:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1211, '2021-02-23 21:27:32', 'I', 'Inclusão de Resposta da 134:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1212, '2021-02-23 21:27:32', 'I', 'Inclusão de Resposta da 137:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1213, '2021-02-23 21:27:32', 'I', 'Inclusão de Resposta da 140:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1214, '2021-02-23 21:27:32', 'I', 'Inclusão de Resposta da 209:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1215, '2021-02-23 21:27:32', 'I', 'Inclusão de Resposta da 214:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1216, '2021-02-23 21:27:32', 'I', 'Inclusão de Resposta da 252:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1217, '2021-02-23 21:27:32', 'I', 'Inclusão de Resposta da 253:Sim - 15:298'),
(11, 1, 1, 'tb_participant', 181, '2021-02-23 21:27:47', 'A', 'Alteração - Prontuario de: 10001000 para 10001001'),
(11, 1, 1, 'tb_formRecord', 247, '2021-03-02 15:01:51', 'I', 'Inclusão de Modulo para paciente: 89'),
(11, 1, 1, 'tb_questiongroupformrecord', 1218, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 53:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1219, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 54:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1220, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 95:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1221, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 130:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1222, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 152:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1223, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 153:Não - 16:300'),
(11, 1, 1, 'tb_questiongroupformrecord', 1224, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 154:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1225, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 167:2021-01-14'),
(11, 1, 1, 'tb_questiongroupformrecord', 1226, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 190:Dor - 2:7'),
(11, 1, 1, 'tb_questiongroupformrecord', 1227, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 207:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1228, '2021-03-02 15:01:51', 'I', 'Inclusão de Resposta da 211:Não - 15:296'),
(11, 1, 1, 'tb_formRecord', 248, '2021-03-02 15:02:43', 'I', 'Inclusão de Modulo para paciente: 89'),
(11, 1, 1, 'tb_questiongroupformrecord', 1229, '2021-03-02 15:02:43', 'I', 'Inclusão de Resposta da 167:2021-03-01'),
(11, 1, 1, 'tb_formRecord', 249, '2021-03-02 15:06:06', 'I', 'Inclusão de Modulo para paciente: 89'),
(11, 1, 1, 'tb_questiongroupformrecord', 1230, '2021-03-02 15:06:06', 'I', 'Inclusão de Resposta da 52:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1231, '2021-03-02 15:06:06', 'I', 'Inclusão de Resposta da 60:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1232, '2021-03-02 15:06:06', 'I', 'Inclusão de Resposta da 108:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1233, '2021-03-02 15:06:06', 'I', 'Inclusão de Resposta da 109:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1234, '2021-03-02 15:06:06', 'I', 'Inclusão de Resposta da 167:2020-12-24'),
(11, 1, 1, 'tb_formRecord', 250, '2021-03-02 17:22:43', 'I', 'Inclusão de Modulo para paciente: 89'),
(11, 1, 1, 'tb_questiongroupformrecord', 1235, '2021-03-02 17:22:43', 'I', 'Inclusão de Resposta da 28:Desconhecido - 15:297'),
(11, 1, 1, 'tb_questiongroupformrecord', 1236, '2021-03-02 17:22:43', 'I', 'Inclusão de Resposta da 168:2021-02-09'),
(11, 1, 1, 'tb_questiongroupformrecord', 1237, '2021-03-02 17:22:43', 'I', 'Inclusão de Resposta da 187:Desconhecido - 15:297'),
(11, 1, 1, 'tb_formRecord', 251, '2021-03-02 18:00:51', 'I', 'Inclusão de Modulo para paciente: 89'),
(11, 1, 1, 'tb_questiongroupformrecord', 1238, '2021-03-02 18:00:51', 'I', 'Inclusão de Resposta da 168:2020-03-16'),
(11, 1, 1, 'tb_formRecord', 252, '2021-03-02 18:05:07', 'I', 'Inclusão de Modulo para paciente: 89'),
(11, 1, 1, 'tb_questiongroupformrecord', 1239, '2021-03-02 18:05:07', 'I', 'Inclusão de Resposta da 168:2020-12-25'),
(11, 1, 1, 'tb_formRecord', 253, '2021-03-02 18:20:40', 'I', 'Inclusão de Modulo para paciente: 89'),
(11, 1, 1, 'tb_questiongroupformrecord', 1240, '2021-03-02 18:20:40', 'I', 'Inclusão de Resposta da 124:2021-03-01'),
(11, 1, 1, 'tb_formRecord', 254, '2021-03-03 21:49:55', 'I', 'Inclusão de Modulo para paciente: 89'),
(11, 1, 1, 'tb_questiongroupformrecord', 1241, '2021-03-03 21:49:55', 'I', 'Inclusão de Resposta da 48:false'),
(11, 1, 1, 'tb_questiongroupformrecord', 1242, '2021-03-03 21:49:55', 'I', 'Inclusão de Resposta da 63:false'),
(11, 1, 1, 'tb_questiongroupformrecord', 1243, '2021-03-03 21:49:55', 'I', 'Inclusão de Resposta da 109:Sim - 15:298'),
(11, 1, 1, 'tb_questiongroupformrecord', 1244, '2021-03-03 21:49:55', 'I', 'Inclusão de Resposta da 167:2021-03-02'),
(11, 1, 1, 'tb_formRecord', 255, '2021-03-03 21:51:33', 'I', 'Inclusão de Modulo para paciente: 89'),
(11, 1, 1, 'tb_questiongroupformrecord', 1245, '2021-03-03 21:51:33', 'I', 'Inclusão de Resposta da 168:2021-03-02'),
(11, 1, 1, 'tb_questiongroupformrecord', 1246, '2021-03-03 21:51:33', 'I', 'Inclusão de Resposta da 218:Não - 15:296'),
(11, 1, 1, 'tb_questiongroupformrecord', 1247, '2021-03-03 21:51:33', 'I', 'Inclusão de Resposta da 220:Não - 15:296'),
(11, 1, 1, 'tb_formRecord', 256, '2021-03-16 17:02:42', 'I', 'Inclusão de Modulo para paciente: 89'),
(11, 1, 1, 'tb_questiongroupformrecord', 1248, '2021-03-16 17:02:42', 'I', 'Inclusão de Resposta da 168:2021-03-15T18:00'),
(11, 1, 1, 'tb_user', 16, '2021-03-16 18:06:42', 'I', 'Inclusão de dados do Usuario: nome@email.com'),
(11, 1, 1, 'tb_user', 17, '2021-03-16 18:20:12', 'I', 'Inclusão de dados do Usuario: nome@email.com'),
(11, 1, 1, 'tb_user', 18, '2021-03-16 18:24:26', 'I', 'Inclusão de dados do Usuario: nome@email.com'),
(11, 1, 1, 'tb_participant', 183, '2021-04-30 18:21:02', 'I', 'Inclusão de paciente: 11223344'),
(11, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-04-30 18:21:02', 'I', 'Inclusão do registro referente ao paciente: 183 para o hospital: 1'),
(11, 1, 1, 'tb_user', 19, '2021-04-30 18:24:42', 'I', 'Inclusão de dados do Usuario: novousuario@email.com'),
(11, 1, 1, 'tb_formRecord', 257, '2021-04-30 18:30:23', 'I', 'Inclusão de Modulo para paciente: 88'),
(11, 1, 1, 'tb_questiongroupformrecord', 1249, '2021-04-30 18:30:23', 'I', 'Inclusão de Resposta da 168:2021-04-28T17:32'),
(11, 1, 1, 'tb_questiongroupformrecord', 1250, '2021-04-30 18:30:23', 'I', 'Inclusão de Resposta da 217:43'),
(11, 1, 1, 'tb_user', 20, '2021-10-12 21:24:24', 'I', 'Inclusão de dados do Usuario: maya@gmail.com'),
(20, 1, 1, 'tb_participant', 184, '2021-10-12 21:49:18', 'I', 'Inclusão de paciente: 1234355345'),
(20, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-10-12 21:49:18', 'I', 'Inclusão do registro referente ao paciente: 184 para o hospital: 1'),
(11, 1, 1, 'tb_user', 21, '2021-10-15 08:33:36', 'I', 'Inclusão de dados do Usuario: shrek@gmail.com'),
(11, 1, 1, 'tb_user', 22, '2021-10-15 08:34:34', 'I', 'Inclusão de dados do Usuario: mayamoraiss@gmail.com'),
(20, 1, 1, 'tb_participant', 185, '2021-11-16 19:39:33', 'I', 'Inclusão de paciente: 657567577'),
(20, 1, 1, 'tb_assessmentquestionnaire', 0, '2021-11-16 19:39:33', 'I', 'Inclusão do registro referente ao paciente: 185 para o hospital: 1'),
(20, 1, 1, 'tb_participant', 185, '2021-11-17 18:38:10', 'A', 'Alteração - Prontuario de: 657567577 para 6575675778');

-- --------------------------------------------------------

--
-- Table structure for table `tb_ontology`
--

CREATE TABLE `tb_ontology` (
  `ontologyID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL,
  `acronym` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `dtRelease` timestamp NULL DEFAULT NULL,
  `license` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tb_ontologyterms`
--

CREATE TABLE `tb_ontologyterms` (
  `ontologyURI` varchar(255) NOT NULL,
  `ontologyID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tb_participant`
--

CREATE TABLE `tb_participant` (
  `participantID` int(10) NOT NULL,
  `medicalRecord` varchar(500) NOT NULL COMMENT '(pt-br) prontuário do paciente. \r\n(en) patient medical record.'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='(pt-br) Tabela para registros de pacientes.\r\n(en) Table for patient records.';

--
-- Dumping data for table `tb_participant`
--

INSERT INTO `tb_participant` (`participantID`, `medicalRecord`) VALUES
(88, '100011583533'),
(89, '100015800495'),
(90, '100016037980'),
(91, '100016342133'),
(92, '100016403455'),
(93, '100016649438'),
(94, '100016712525'),
(95, '100017029697'),
(96, '100017201734'),
(97, '100017312028'),
(98, '100017339039'),
(99, '100017339997'),
(100, '100017446628'),
(101, '100017454192'),
(102, '100017494263'),
(103, '100017572316'),
(104, '100017600000'),
(105, '100017612534'),
(106, '100017612955'),
(107, '100017629702'),
(108, '100017632672'),
(109, '100017641384'),
(110, '100017643869'),
(111, '100017691801'),
(112, '100017737315'),
(113, '100017789100'),
(114, '100017821218'),
(115, '100017833114'),
(116, '100017857592'),
(117, '100017862519'),
(118, '100017882038'),
(119, '100017887391'),
(120, '100017895154'),
(121, '100017895352'),
(122, '100017895402'),
(123, '100017895436'),
(124, '100017895626'),
(125, '100017895659'),
(126, '100017895709'),
(127, '100017895774'),
(128, '100017895790'),
(129, '100017895808'),
(130, '100017895816'),
(131, '100017895824'),
(132, '100017895881'),
(133, '100017895915'),
(134, '100017895998'),
(135, '100017896053'),
(136, '100017896061'),
(137, '100017896244'),
(138, '100017896269'),
(139, '100017896285'),
(140, '100017896392'),
(141, '100017896442'),
(142, '100017896517'),
(143, '100017896525'),
(144, '100017896590'),
(145, '100017896673'),
(146, '100017896681'),
(147, '100017896699'),
(148, '100017896707'),
(149, '100017896822'),
(150, '100017896830'),
(151, '100017896863'),
(152, '100017896889'),
(153, '100017896988'),
(154, '100017897085'),
(155, '100017897101'),
(156, '100017897119'),
(157, '100017897143'),
(158, '100017897234'),
(159, '100017897333'),
(160, '100017897408'),
(161, '100017897473'),
(162, '100017897689'),
(163, '100017898349'),
(164, '100017898372'),
(165, '100017898521'),
(166, '100017898737'),
(167, '808080808080'),
(168, '808080808081'),
(169, '808080808082'),
(170, '808080808888'),
(172, '808080808891'),
(173, '123456'),
(174, '1234567'),
(175, '12345678'),
(176, '123456789'),
(177, '1234567890'),
(178, '1234567'),
(179, '111'),
(180, '9876543210'),
(181, '10001001'),
(182, '12345678910'),
(183, '11223344'),
(184, '1234355345'),
(185, '6575675778');

-- --------------------------------------------------------

--
-- Table structure for table `tb_permission`
--

CREATE TABLE `tb_permission` (
  `permissionID` bigint(20) UNSIGNED NOT NULL,
  `description` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_permission`
--

INSERT INTO `tb_permission` (`permissionID`, `description`) VALUES
(1, 'Insert'),
(2, 'Update'),
(3, 'Delete'),
(4, 'ALL');

-- --------------------------------------------------------

--
-- Table structure for table `tb_questiongroup`
--

CREATE TABLE `tb_questiongroup` (
  `questionGroupID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL COMMENT '(pt-br) Descrição.\r\n(en) description.',
  `comment` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Relacionado ao Question Group da ontologia relaciona as diversas sessoes existentes nos formularios do CRF COVID-19';

--
-- Dumping data for table `tb_questiongroup`
--

INSERT INTO `tb_questiongroup` (`questionGroupID`, `description`, `comment`) VALUES
(1, 'Clinical inclusion criteria', ''),
(2, 'Co-morbidities', 'Existing conditions prior to admission.'),
(3, 'Complications', ''),
(4, 'Daily clinical features', ''),
(5, 'Date of onset and admission vital signs', 'first available data at presentation/admission'),
(6, 'Demographics', ''),
(7, 'Diagnostic/pathogen testing', ''),
(8, 'Laboratory results', ''),
(9, 'Medication', 'Is the patient CURRENTLY receiving any of the following?'),
(10, 'Outcome', ''),
(11, 'Pre-admission & chronic medication', 'Were any of the following taken within 14 days of admission?'),
(12, 'Signs and symptoms on admission', ''),
(13, 'Supportive care', 'Is the patient CURRENTLY receiving any of the following?'),
(14, 'Vital signs', '');

-- --------------------------------------------------------

--
-- Table structure for table `tb_questiongroupform`
--

CREATE TABLE `tb_questiongroupform` (
  `crfFormsID` int(10) NOT NULL,
  `questionID` int(10) NOT NULL,
  `questionOrder` int(10) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_questiongroupform`
--

INSERT INTO `tb_questiongroupform` (`crfFormsID`, `questionID`, `questionOrder`) VALUES
(1, 29, 10629),
(1, 33, 10710),
(1, 34, 10711),
(1, 35, 10703),
(1, 36, 10706),
(1, 37, 10713),
(1, 38, 10627),
(1, 39, 10802),
(1, 40, 10310),
(1, 47, 10102),
(1, 48, 10105),
(1, 49, 10101),
(1, 50, 10404),
(1, 51, 10412),
(1, 52, 10401),
(1, 53, 10405),
(1, 54, 10406),
(1, 55, 10407),
(1, 56, 10403),
(1, 57, 10410),
(1, 58, 10409),
(1, 59, 10408),
(1, 60, 10402),
(1, 61, 10413),
(1, 62, 10414),
(1, 63, 10104),
(1, 64, 10103),
(1, 65, 10411),
(1, 82, 10707),
(1, 87, 10708),
(1, 89, 10803),
(1, 90, 10805),
(1, 91, 10628),
(1, 92, 10804),
(1, 93, 10302),
(1, 94, 10316),
(1, 95, 10314),
(1, 96, 10315),
(1, 97, 10301),
(1, 98, 10317),
(1, 100, 10712),
(1, 101, 10704),
(1, 103, 10714),
(1, 104, 10705),
(1, 107, 10202),
(1, 108, 10205),
(1, 109, 10206),
(1, 110, 10207),
(1, 111, 10201),
(1, 113, 10208),
(1, 114, 10908),
(1, 115, 10905),
(1, 116, 10910),
(1, 117, 10709),
(1, 118, 10921),
(1, 119, 10702),
(1, 120, 10701),
(1, 127, 10619),
(1, 128, 10604),
(1, 129, 10611),
(1, 130, 10616),
(1, 132, 10601),
(1, 133, 10626),
(1, 134, 10610),
(1, 135, 10615),
(1, 136, 10625),
(1, 137, 10606),
(1, 138, 10623),
(1, 139, 10624),
(1, 140, 10607),
(1, 141, 10311),
(1, 143, 10630),
(1, 144, 10204),
(1, 145, 10919),
(1, 146, 10913),
(1, 147, 10917),
(1, 148, 10922),
(1, 149, 10815),
(1, 150, 10801),
(1, 151, 10814),
(1, 152, 10808),
(1, 153, 10806),
(1, 154, 10807),
(1, 155, 10816),
(1, 156, 10923),
(1, 157, 10903),
(1, 158, 10901),
(1, 159, 10924),
(1, 160, 10907),
(1, 161, 10912),
(1, 162, 10918),
(1, 163, 10904),
(1, 164, 10915),
(1, 165, 10916),
(1, 166, 10003),
(1, 167, 10004),
(1, 169, 10906),
(1, 170, 10914),
(1, 171, 10909),
(1, 172, 10920),
(1, 174, 10911),
(1, 189, 10308),
(1, 190, 10312),
(1, 191, 10304),
(1, 192, 10307),
(1, 193, 10313),
(1, 194, 10305),
(1, 195, 10306),
(1, 196, 10309),
(1, 198, 10303),
(1, 199, 10715),
(1, 200, 10716),
(1, 201, 10717),
(1, 202, 10501),
(1, 203, 10502),
(1, 204, 10503),
(1, 205, 10614),
(1, 206, 10620),
(1, 207, 10617),
(1, 208, 10621),
(1, 209, 10609),
(1, 210, 10602),
(1, 211, 10618),
(1, 212, 10203),
(1, 213, 10622),
(1, 214, 10608),
(1, 215, 10605),
(1, 225, 10603),
(1, 226, 10902),
(1, 227, 10415),
(1, 241, 10718),
(1, 242, 10002),
(1, 245, 10810),
(1, 246, 10813),
(1, 247, 10812),
(1, 248, 10811),
(1, 249, 10809),
(1, 252, 10613),
(1, 253, 10612),
(1, 254, 10504),
(1, 255, 10505),
(2, 28, 20214),
(2, 33, 20410),
(2, 34, 20411),
(2, 35, 20403),
(2, 36, 20406),
(2, 37, 20413),
(2, 39, 20504),
(2, 41, 20109),
(2, 82, 20407),
(2, 83, 20208),
(2, 87, 20408),
(2, 89, 20505),
(2, 90, 20507),
(2, 92, 20506),
(2, 100, 20412),
(2, 101, 20404),
(2, 103, 20414),
(2, 104, 20405),
(2, 112, 20110),
(2, 114, 20308),
(2, 115, 20305),
(2, 116, 20310),
(2, 117, 20409),
(2, 118, 20321),
(2, 119, 20402),
(2, 120, 20401),
(2, 142, 20215),
(2, 145, 20319),
(2, 146, 20313),
(2, 147, 20317),
(2, 148, 20322),
(2, 149, 20516),
(2, 150, 20501),
(2, 151, 20517),
(2, 152, 20510),
(2, 153, 20508),
(2, 154, 20509),
(2, 155, 20518),
(2, 156, 20323),
(2, 157, 20303),
(2, 158, 20301),
(2, 159, 20324),
(2, 160, 20307),
(2, 161, 20312),
(2, 162, 20318),
(2, 163, 20304),
(2, 164, 20315),
(2, 165, 20316),
(2, 168, 20002),
(2, 169, 20306),
(2, 170, 20314),
(2, 171, 20309),
(2, 172, 20320),
(2, 174, 20311),
(2, 177, 20204),
(2, 178, 20209),
(2, 182, 20210),
(2, 183, 20201),
(2, 184, 20203),
(2, 185, 20205),
(2, 186, 20211),
(2, 187, 20213),
(2, 188, 20212),
(2, 197, 20202),
(2, 199, 20415),
(2, 200, 20416),
(2, 201, 20417),
(2, 216, 20111),
(2, 217, 20101),
(2, 218, 20107),
(2, 219, 20105),
(2, 220, 20106),
(2, 221, 20102),
(2, 222, 20104),
(2, 223, 20108),
(2, 224, 20103),
(2, 226, 20302),
(2, 228, 20502),
(2, 229, 20503),
(2, 241, 20418),
(2, 245, 20512),
(2, 246, 20515),
(2, 247, 20514),
(2, 248, 20513),
(2, 249, 20511),
(2, 250, 20206),
(2, 251, 20207),
(3, 30, 30218),
(3, 31, 30101),
(3, 32, 30103),
(3, 33, 30311),
(3, 34, 30313),
(3, 35, 30303),
(3, 36, 30308),
(3, 37, 30315),
(3, 39, 30404),
(3, 42, 30109),
(3, 43, 30111),
(3, 44, 30106),
(3, 45, 30107),
(3, 46, 30104),
(3, 66, 30214),
(3, 67, 30209),
(3, 68, 30204),
(3, 69, 30210),
(3, 70, 30211),
(3, 71, 30208),
(3, 72, 30206),
(3, 73, 30205),
(3, 74, 30217),
(3, 75, 30212),
(3, 76, 30216),
(3, 77, 30203),
(3, 78, 30213),
(3, 79, 30215),
(3, 80, 30207),
(3, 81, 30201),
(3, 82, 30309),
(3, 84, 30114),
(3, 85, 30116),
(3, 86, 30102),
(3, 87, 30310),
(3, 88, 30115),
(3, 89, 30406),
(3, 90, 30408),
(3, 92, 30407),
(3, 99, 30312),
(3, 100, 30314),
(3, 101, 30304),
(3, 102, 30219),
(3, 103, 30316),
(3, 104, 30305),
(3, 105, 30113),
(3, 106, 30108),
(3, 117, 30306),
(3, 119, 30302),
(3, 120, 30301),
(3, 121, 30105),
(3, 122, 30503),
(3, 123, 30501),
(3, 124, 30502),
(3, 125, 30110),
(3, 126, 30112),
(3, 149, 30413),
(3, 150, 30401),
(3, 151, 30418),
(3, 152, 30411),
(3, 153, 30409),
(3, 154, 30415),
(3, 155, 30417),
(3, 176, 30202),
(3, 180, 30318),
(3, 199, 30317),
(3, 228, 30403),
(3, 232, 30307),
(3, 233, 30402),
(3, 234, 30405),
(3, 235, 30410),
(3, 236, 30412),
(3, 237, 30414),
(3, 238, 30416),
(3, 240, 30419);

-- --------------------------------------------------------

--
-- Table structure for table `tb_questiongroupformrecord`
--

CREATE TABLE `tb_questiongroupformrecord` (
  `questionGroupFormRecordID` int(10) NOT NULL,
  `formRecordID` int(10) NOT NULL,
  `crfFormsID` int(10) NOT NULL,
  `questionID` int(10) NOT NULL,
  `listOfValuesID` int(10) DEFAULT NULL,
  `answer` varchar(512) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='(pt-br) Tabela para registro da resposta associada a uma questão de um agrupamento de um formulário referente a um questionario de avaliação.\r\n(en) Form record table.';

--
-- Dumping data for table `tb_questiongroupformrecord`
--

INSERT INTO `tb_questiongroupformrecord` (`questionGroupFormRecordID`, `formRecordID`, `crfFormsID`, `questionID`, `listOfValuesID`, `answer`) VALUES
(1, 82, 1, 107, NULL, '18/11/1936'),
(2, 82, 1, 111, 284, NULL),
(3, 82, 1, 144, NULL, '83'),
(4, 82, 1, 166, 45, NULL),
(5, 82, 1, 167, NULL, '2020-04-30'),
(7, 83, 2, 35, 298, NULL),
(8, 83, 2, 101, 306, NULL),
(9, 83, 2, 101, 305, NULL),
(10, 83, 2, 150, 296, ''),
(11, 83, 2, 168, NULL, '2020-04-30'),
(12, 84, 3, 35, 298, NULL),
(13, 84, 3, 101, 305, NULL),
(14, 84, 3, 101, 306, NULL),
(15, 84, 3, 123, 276, NULL),
(16, 84, 3, 124, NULL, '2020-05-13'),
(17, 220, 1, 107, NULL, '30/10/1926'),
(18, 220, 1, 111, 284, NULL),
(19, 220, 1, 144, NULL, '93'),
(20, 220, 1, 166, 45, NULL),
(21, 220, 1, 167, NULL, '2020-03-06'),
(23, 221, 2, 35, 298, NULL),
(24, 221, 2, 101, 305, NULL),
(25, 221, 2, 150, 298, NULL),
(26, 221, 2, 168, NULL, '2020-03-06'),
(27, 221, 2, 228, NULL, '2020-03-06'),
(28, 222, 3, 35, 298, NULL),
(29, 222, 3, 101, 305, NULL),
(30, 222, 3, 123, 275, NULL),
(31, 222, 3, 124, NULL, '2020-06-13'),
(32, 145, 1, 107, NULL, '29/07/1961'),
(33, 145, 1, 111, 285, NULL),
(34, 145, 1, 144, NULL, '58'),
(35, 145, 1, 166, 45, NULL),
(36, 145, 1, 167, NULL, '2020-05-13'),
(38, 146, 2, 35, 298, NULL),
(39, 146, 2, 101, 305, NULL),
(40, 146, 2, 150, 300, NULL),
(41, 146, 2, 168, NULL, '2020-05-13'),
(42, 147, 3, 35, 298, NULL),
(43, 147, 3, 101, 305, NULL),
(44, 147, 3, 123, 276, NULL),
(45, 147, 3, 124, NULL, '2020-05-19'),
(46, 193, 1, 107, NULL, '22/05/1989'),
(47, 193, 1, 111, 284, NULL),
(48, 193, 1, 144, NULL, '31'),
(49, 193, 1, 166, 45, NULL),
(50, 193, 1, 167, NULL, '2020-05-22'),
(52, 194, 2, 35, 298, NULL),
(53, 194, 2, 101, 305, NULL),
(54, 194, 2, 150, 300, NULL),
(55, 194, 2, 168, NULL, '2020-05-22'),
(56, 195, 3, 35, 298, NULL),
(57, 195, 3, 101, 305, NULL),
(58, 195, 3, 123, 276, NULL),
(59, 195, 3, 124, NULL, '2020-05-23'),
(60, 148, 1, 107, NULL, '26/04/1980'),
(61, 148, 1, 111, 285, NULL),
(62, 148, 1, 144, NULL, '40'),
(63, 148, 1, 166, 45, NULL),
(64, 148, 1, 167, NULL, '2020-05-13'),
(66, 149, 2, 35, 298, NULL),
(67, 149, 2, 101, 305, NULL),
(68, 149, 2, 101, 306, NULL),
(69, 149, 2, 150, 300, NULL),
(70, 149, 2, 168, NULL, '2020-05-13'),
(71, 150, 3, 35, 298, NULL),
(72, 150, 3, 101, 305, NULL),
(73, 150, 3, 101, 306, NULL),
(74, 150, 3, 123, 276, NULL),
(75, 150, 3, 124, NULL, '2020-05-14'),
(76, 10, 1, 107, NULL, '18/01/1955'),
(77, 10, 1, 111, 285, NULL),
(78, 10, 1, 144, NULL, '65'),
(79, 10, 1, 166, 45, NULL),
(80, 10, 1, 167, NULL, '2020-04-13'),
(82, 11, 2, 35, 298, NULL),
(83, 11, 2, 101, 306, NULL),
(84, 11, 2, 101, 305, NULL),
(85, 11, 2, 150, 298, NULL),
(86, 11, 2, 168, NULL, '2020-04-13'),
(87, 11, 2, 228, NULL, '2020-04-13'),
(88, 12, 3, 35, 298, NULL),
(89, 12, 3, 101, 305, NULL),
(90, 12, 3, 101, 306, NULL),
(91, 12, 3, 123, 275, NULL),
(92, 12, 3, 124, NULL, '2020-05-13'),
(93, 64, 1, 107, NULL, '24/01/1975'),
(94, 64, 1, 111, 284, NULL),
(95, 64, 1, 144, NULL, '45'),
(96, 64, 1, 166, 45, NULL),
(97, 64, 1, 167, NULL, '2020-04-26'),
(99, 65, 2, 35, 298, NULL),
(100, 65, 2, 101, 305, NULL),
(101, 65, 2, 101, 306, NULL),
(102, 65, 2, 150, 300, NULL),
(103, 65, 2, 168, NULL, '2020-04-26'),
(104, 66, 3, 35, 298, NULL),
(105, 66, 3, 101, 306, NULL),
(106, 66, 3, 101, 305, NULL),
(107, 66, 3, 123, 276, NULL),
(108, 66, 3, 124, NULL, '2020-04-29'),
(109, 55, 1, 107, NULL, '23/02/1949'),
(110, 55, 1, 111, 285, NULL),
(111, 55, 1, 144, NULL, '71'),
(112, 55, 1, 166, 45, NULL),
(113, 55, 1, 167, NULL, '2020-04-24'),
(115, 56, 2, 35, 298, NULL),
(116, 56, 2, 101, 305, NULL),
(117, 56, 2, 101, 306, NULL),
(118, 56, 2, 150, 300, NULL),
(119, 56, 2, 168, NULL, '2020-04-24'),
(120, 57, 3, 35, 298, NULL),
(121, 57, 3, 101, 305, NULL),
(122, 57, 3, 101, 306, NULL),
(123, 57, 3, 123, 276, NULL),
(124, 57, 3, 124, NULL, '2020-05-12'),
(125, 97, 1, 107, NULL, '03/01/1964'),
(126, 97, 1, 111, 285, NULL),
(127, 97, 1, 144, NULL, '56'),
(128, 97, 1, 166, 45, NULL),
(129, 97, 1, 167, NULL, '2020-04-05'),
(131, 98, 2, 35, 298, NULL),
(132, 98, 2, 101, 306, NULL),
(133, 98, 2, 101, 305, NULL),
(134, 98, 2, 150, 300, NULL),
(135, 98, 2, 168, NULL, '2020-04-05'),
(136, 99, 3, 35, 298, NULL),
(137, 99, 3, 101, 306, NULL),
(138, 99, 3, 101, 305, NULL),
(139, 99, 3, 123, 276, NULL),
(140, 99, 3, 124, NULL, '2020-05-07'),
(141, 94, 1, 107, NULL, '29/06/1974'),
(142, 94, 1, 111, 284, NULL),
(143, 94, 1, 144, NULL, '45'),
(144, 94, 1, 166, 45, NULL),
(145, 94, 1, 167, NULL, '2020-03-05'),
(147, 95, 2, 35, 298, NULL),
(148, 95, 2, 101, 305, NULL),
(149, 95, 2, 101, 306, NULL),
(150, 95, 2, 150, 300, NULL),
(151, 95, 2, 168, NULL, '2020-03-05'),
(152, 96, 3, 35, 298, NULL),
(153, 96, 3, 101, 305, NULL),
(154, 96, 3, 101, 306, NULL),
(155, 96, 3, 123, 276, NULL),
(156, 96, 3, 124, NULL, '2020-05-07'),
(157, 4, 1, 167, NULL, '2020-03-05'),
(158, 5, 2, 35, 298, NULL),
(159, 5, 2, 101, 305, NULL),
(160, 5, 2, 168, NULL, '2020-03-05'),
(161, 5, 2, 228, NULL, '2020-03-05'),
(162, 6, 3, 35, 298, NULL),
(163, 6, 3, 101, 305, NULL),
(164, 6, 3, 123, 275, NULL),
(165, 6, 3, 124, NULL, '2020-04-27'),
(166, 40, 1, 107, NULL, '25/05/1960'),
(167, 40, 1, 111, 285, NULL),
(168, 40, 1, 144, NULL, '60'),
(169, 40, 1, 166, 45, NULL),
(170, 40, 1, 167, NULL, '2020-04-22'),
(172, 41, 2, 35, 298, NULL),
(173, 41, 2, 101, 305, NULL),
(174, 41, 2, 101, 306, NULL),
(175, 41, 2, 150, 300, NULL),
(176, 41, 2, 168, NULL, '2020-04-22'),
(177, 42, 3, 35, 298, NULL),
(178, 42, 3, 101, 305, NULL),
(179, 42, 3, 101, 306, NULL),
(180, 42, 3, 123, 276, NULL),
(181, 42, 3, 124, NULL, '2020-02-05'),
(182, 202, 1, 107, NULL, '21/12/1951'),
(183, 202, 1, 111, 285, NULL),
(184, 202, 1, 144, NULL, '68'),
(185, 202, 1, 166, 45, NULL),
(186, 202, 1, 167, NULL, '2020-05-25'),
(188, 203, 2, 35, 298, NULL),
(189, 203, 2, 101, 305, NULL),
(190, 203, 2, 150, 300, NULL),
(191, 203, 2, 168, NULL, '2020-05-25'),
(192, 204, 3, 35, 298, NULL),
(193, 204, 3, 101, 305, NULL),
(194, 204, 3, 123, 276, NULL),
(195, 204, 3, 124, NULL, '2020-01-06'),
(196, 67, 1, 107, NULL, '30/08/1972'),
(197, 67, 1, 111, 284, NULL),
(198, 67, 1, 144, NULL, '47'),
(199, 67, 1, 166, 45, NULL),
(200, 67, 1, 167, NULL, '2020-04-27'),
(202, 68, 2, 35, 298, NULL),
(203, 68, 2, 101, 306, NULL),
(204, 68, 2, 101, 305, NULL),
(205, 68, 2, 150, 300, NULL),
(206, 68, 2, 168, NULL, '2020-04-27'),
(207, 69, 3, 35, 298, NULL),
(208, 69, 3, 101, 306, NULL),
(209, 69, 3, 101, 305, NULL),
(210, 69, 3, 123, 276, NULL),
(211, 69, 3, 124, NULL, '2020-05-06'),
(212, 103, 1, 107, NULL, '14/09/1959'),
(213, 103, 1, 111, 284, NULL),
(214, 103, 1, 144, NULL, '60'),
(215, 103, 1, 166, 45, NULL),
(216, 103, 1, 167, NULL, '2020-05-05'),
(218, 104, 2, 150, 300, NULL),
(219, 104, 2, 168, NULL, '2020-05-05'),
(220, 105, 3, 123, 276, NULL),
(221, 105, 3, 124, NULL, '2020-05-12'),
(222, 184, 1, 107, NULL, '10/11/1934'),
(223, 184, 1, 111, 285, NULL),
(224, 184, 1, 144, NULL, '85'),
(225, 184, 1, 166, 45, NULL),
(226, 184, 1, 167, NULL, '2020-05-21'),
(228, 185, 2, 150, 300, NULL),
(229, 185, 2, 168, NULL, '2020-05-21'),
(230, 186, 3, 123, 276, NULL),
(231, 186, 3, 124, NULL, '2020-06-13'),
(232, 25, 1, 107, NULL, '02/08/1974'),
(233, 25, 1, 111, 285, NULL),
(234, 25, 1, 144, NULL, '45'),
(235, 25, 1, 166, 45, NULL),
(236, 25, 1, 167, NULL, '2020-04-19'),
(238, 26, 2, 35, 298, NULL),
(239, 26, 2, 101, 306, NULL),
(240, 26, 2, 101, 305, NULL),
(241, 26, 2, 150, 300, NULL),
(242, 26, 2, 168, NULL, '2020-04-19'),
(243, 27, 3, 35, 298, NULL),
(244, 27, 3, 101, 305, NULL),
(245, 27, 3, 101, 306, NULL),
(246, 27, 3, 123, 276, NULL),
(247, 27, 3, 124, NULL, '2020-05-24'),
(248, 19, 1, 107, NULL, '18/01/1965'),
(249, 19, 1, 111, 285, NULL),
(250, 19, 1, 144, NULL, '55'),
(251, 19, 1, 166, 45, NULL),
(252, 19, 1, 167, NULL, '2020-04-15'),
(254, 20, 2, 35, 298, NULL),
(255, 20, 2, 101, 305, NULL),
(256, 20, 2, 101, 3, NULL),
(257, 20, 2, 101, 306, NULL),
(258, 20, 2, 150, 300, NULL),
(259, 20, 2, 168, NULL, '2020-04-15'),
(260, 21, 3, 35, 298, NULL),
(261, 21, 3, 101, 3, NULL),
(262, 21, 3, 101, 305, NULL),
(263, 21, 3, 101, 306, NULL),
(264, 21, 3, 123, 276, NULL),
(265, 21, 3, 124, NULL, '2020-04-20'),
(266, 196, 1, 107, NULL, '17/07/1962'),
(267, 196, 1, 111, 285, NULL),
(268, 196, 1, 144, NULL, '57'),
(269, 196, 1, 166, 45, NULL),
(270, 196, 1, 167, NULL, '2020-05-23'),
(272, 197, 2, 35, 298, NULL),
(273, 197, 2, 101, 305, NULL),
(274, 197, 2, 150, 300, NULL),
(275, 197, 2, 168, NULL, '2020-05-23'),
(276, 198, 3, 35, 298, NULL),
(277, 198, 3, 101, 305, NULL),
(278, 198, 3, 123, 276, NULL),
(279, 198, 3, 124, NULL, '2020-02-06'),
(280, 151, 1, 107, NULL, '25/12/1982'),
(281, 151, 1, 111, 284, NULL),
(282, 151, 1, 144, NULL, '37'),
(283, 151, 1, 166, 45, NULL),
(284, 151, 1, 167, NULL, '2020-05-14'),
(286, 152, 2, 35, 298, NULL),
(287, 152, 2, 101, 305, NULL),
(288, 152, 2, 150, 300, NULL),
(289, 152, 2, 168, NULL, '2020-05-14'),
(290, 153, 3, 35, 298, NULL),
(291, 153, 3, 101, 305, NULL),
(292, 153, 3, 123, 276, NULL),
(293, 153, 3, 124, NULL, '2020-05-16'),
(294, 214, 1, 107, NULL, '19/10/1961'),
(295, 214, 1, 111, 285, NULL),
(296, 214, 1, 144, NULL, '58'),
(297, 214, 1, 166, 45, NULL),
(298, 214, 1, 167, NULL, '2020-05-31'),
(300, 215, 2, 35, 298, NULL),
(301, 215, 2, 101, 305, NULL),
(302, 215, 2, 150, 300, NULL),
(303, 215, 2, 168, NULL, '2020-05-31'),
(304, 216, 3, 35, 298, NULL),
(305, 216, 3, 101, 305, NULL),
(306, 216, 3, 123, 276, NULL),
(307, 216, 3, 124, NULL, '2020-04-06'),
(308, 169, 1, 107, NULL, '18/06/1959'),
(309, 169, 1, 111, 285, NULL),
(310, 169, 1, 144, NULL, '61'),
(311, 169, 1, 166, 45, NULL),
(312, 169, 1, 167, NULL, '2020-05-18'),
(314, 170, 2, 35, 298, NULL),
(315, 170, 2, 101, 305, NULL),
(316, 170, 2, 150, 300, NULL),
(317, 170, 2, 168, NULL, '2020-05-18'),
(318, 171, 3, 35, 298, NULL),
(319, 171, 3, 101, 305, NULL),
(320, 171, 3, 123, 276, NULL),
(321, 171, 3, 124, NULL, '2020-05-26'),
(322, 118, 1, 107, NULL, '13/06/1936'),
(323, 118, 1, 111, 285, NULL),
(324, 118, 1, 144, NULL, '84'),
(325, 118, 1, 166, 45, NULL),
(326, 118, 1, 167, NULL, '2020-05-07'),
(328, 119, 2, 35, 298, NULL),
(329, 119, 2, 101, 306, NULL),
(330, 119, 2, 101, 305, NULL),
(331, 119, 2, 150, 300, NULL),
(332, 119, 2, 168, NULL, '2020-05-07'),
(333, 120, 3, 35, 298, NULL),
(334, 120, 3, 101, 305, NULL),
(335, 120, 3, 101, 306, NULL),
(336, 120, 3, 123, 276, NULL),
(337, 120, 3, 124, NULL, '2020-05-21'),
(338, 109, 1, 107, NULL, '10/08/1938'),
(339, 109, 1, 111, 284, NULL),
(340, 109, 1, 144, NULL, '81'),
(341, 109, 1, 166, 45, NULL),
(342, 109, 1, 167, NULL, '2020-05-06'),
(344, 110, 2, 35, 298, NULL),
(345, 110, 2, 101, 305, NULL),
(346, 110, 2, 101, 306, NULL),
(347, 110, 2, 150, 298, NULL),
(348, 110, 2, 168, NULL, '2020-05-06'),
(349, 110, 2, 228, NULL, '2020-05-06'),
(350, 111, 3, 35, 298, NULL),
(351, 111, 3, 101, 306, NULL),
(352, 111, 3, 101, 305, NULL),
(353, 111, 3, 123, 275, NULL),
(354, 111, 3, 124, NULL, '2020-05-13'),
(355, 142, 1, 107, NULL, '27/01/1957'),
(356, 142, 1, 111, 285, NULL),
(357, 142, 1, 144, NULL, '63'),
(358, 142, 1, 166, 45, NULL),
(359, 142, 1, 167, NULL, '2020-05-13'),
(361, 143, 2, 35, 298, NULL),
(362, 143, 2, 101, 305, NULL),
(363, 143, 2, 150, 300, NULL),
(364, 143, 2, 168, NULL, '2020-05-13'),
(365, 144, 3, 35, 298, NULL),
(366, 144, 3, 101, 305, NULL),
(367, 144, 3, 123, 276, NULL),
(368, 144, 3, 124, NULL, '2020-05-21'),
(369, 22, 1, 107, NULL, '21/12/1963'),
(370, 22, 1, 111, 285, NULL),
(371, 22, 1, 144, NULL, '56'),
(372, 22, 1, 166, 45, NULL),
(373, 22, 1, 167, NULL, '2020-04-17'),
(375, 23, 2, 35, 298, NULL),
(376, 23, 2, 101, 305, NULL),
(377, 23, 2, 101, 306, NULL),
(378, 23, 2, 150, 300, NULL),
(379, 23, 2, 168, NULL, '2020-04-17'),
(380, 24, 3, 35, 298, NULL),
(381, 24, 3, 101, 306, NULL),
(382, 24, 3, 101, 305, NULL),
(383, 24, 3, 123, 276, NULL),
(384, 24, 3, 124, NULL, '2020-04-29'),
(385, 217, 1, 107, NULL, '14/09/1938'),
(386, 217, 1, 111, 285, NULL),
(387, 217, 1, 144, NULL, '81'),
(388, 217, 1, 166, 45, NULL),
(389, 217, 1, 167, NULL, '2020-01-06'),
(391, 218, 2, 35, 298, NULL),
(392, 218, 2, 101, 305, NULL),
(393, 218, 2, 150, 300, NULL),
(394, 218, 2, 168, NULL, '2020-01-06'),
(395, 219, 3, 35, 298, NULL),
(396, 219, 3, 101, 305, NULL),
(397, 219, 3, 123, 276, NULL),
(398, 219, 3, 124, NULL, '2020-06-09'),
(399, 154, 1, 107, NULL, '13/01/1998'),
(400, 154, 1, 111, 285, NULL),
(401, 154, 1, 144, NULL, '22'),
(402, 154, 1, 166, 45, NULL),
(403, 154, 1, 167, NULL, '2020-05-14'),
(405, 155, 2, 35, 298, NULL),
(406, 155, 2, 101, 305, NULL),
(407, 155, 2, 150, 300, NULL),
(408, 155, 2, 168, NULL, '2020-05-14'),
(409, 156, 3, 35, 298, NULL),
(410, 156, 3, 101, 305, NULL),
(411, 156, 3, 123, 276, NULL),
(412, 156, 3, 124, NULL, '2020-05-22'),
(413, 1, 1, 167, NULL, '2020-01-24'),
(414, 2, 2, 35, 298, NULL),
(415, 2, 2, 101, 306, NULL),
(416, 2, 2, 168, NULL, '2020-01-24'),
(417, 3, 3, 35, 298, NULL),
(418, 3, 3, 101, 306, NULL),
(419, 3, 3, 123, 275, NULL),
(420, 3, 3, 124, NULL, '2020-05-12'),
(421, 112, 1, 107, NULL, '28/07/1994'),
(422, 112, 1, 111, 284, NULL),
(423, 112, 1, 144, NULL, '25'),
(424, 112, 1, 166, 45, NULL),
(425, 112, 1, 167, NULL, '2020-05-06'),
(427, 113, 2, 35, 298, NULL),
(428, 113, 2, 101, 305, NULL),
(429, 113, 2, 150, 300, NULL),
(430, 113, 2, 168, NULL, '2020-05-06'),
(431, 114, 3, 35, 298, NULL),
(432, 114, 3, 101, 305, NULL),
(433, 114, 3, 123, 276, NULL),
(434, 114, 3, 124, NULL, '2020-05-08'),
(435, 115, 1, 107, NULL, '16/09/1985'),
(436, 115, 1, 111, 285, NULL),
(437, 115, 1, 144, NULL, '34'),
(438, 115, 1, 166, 45, NULL),
(439, 115, 1, 167, NULL, '2020-05-07'),
(441, 116, 2, 35, 298, NULL),
(442, 116, 2, 101, 306, NULL),
(443, 116, 2, 150, 300, NULL),
(444, 116, 2, 168, NULL, '2020-05-07'),
(445, 117, 3, 35, 298, NULL),
(446, 117, 3, 101, 306, NULL),
(447, 117, 3, 123, 276, NULL),
(448, 117, 3, 124, NULL, '2020-05-11'),
(449, 79, 1, 107, NULL, '25/03/1952'),
(450, 79, 1, 111, 285, NULL),
(451, 79, 1, 144, NULL, '68'),
(452, 79, 1, 166, 45, NULL),
(453, 79, 1, 167, NULL, '2020-04-28'),
(455, 80, 2, 35, 298, NULL),
(456, 80, 2, 101, 306, NULL),
(457, 80, 2, 101, 305, NULL),
(458, 80, 2, 150, 300, NULL),
(459, 80, 2, 168, NULL, '2020-04-28'),
(460, 81, 3, 35, 298, NULL),
(461, 81, 3, 101, 306, NULL),
(462, 81, 3, 101, 305, NULL),
(463, 81, 3, 123, 276, NULL),
(464, 81, 3, 124, NULL, '2020-05-16'),
(465, 7, 1, 107, NULL, '18/11/1952'),
(466, 7, 1, 111, 284, NULL),
(467, 7, 1, 144, NULL, '67'),
(468, 7, 1, 166, 45, NULL),
(469, 7, 1, 167, NULL, '2020-04-10'),
(471, 8, 2, 35, 298, NULL),
(472, 8, 2, 101, 306, NULL),
(473, 8, 2, 101, 305, NULL),
(474, 8, 2, 150, 298, NULL),
(475, 8, 2, 168, NULL, '2020-04-10'),
(476, 8, 2, 228, NULL, '2020-04-10'),
(477, 9, 3, 35, 298, NULL),
(478, 9, 3, 101, 306, NULL),
(479, 9, 3, 101, 305, NULL),
(480, 9, 3, 123, 275, NULL),
(481, 9, 3, 124, NULL, '2020-05-07'),
(482, 223, 1, 107, NULL, '23/11/1989'),
(483, 223, 1, 111, 285, NULL),
(484, 223, 1, 144, NULL, '30'),
(485, 223, 1, 166, 45, NULL),
(486, 223, 1, 167, NULL, '2020-03-06'),
(488, 224, 2, 35, 298, NULL),
(489, 224, 2, 101, 305, NULL),
(490, 224, 2, 101, 3, NULL),
(491, 224, 2, 150, 298, NULL),
(492, 224, 2, 168, NULL, '2020-03-06'),
(493, 224, 2, 228, NULL, '2020-03-06'),
(494, 225, 3, 35, 298, NULL),
(495, 225, 3, 101, 3, NULL),
(496, 225, 3, 101, 305, NULL),
(497, 225, 3, 123, 275, NULL),
(498, 225, 3, 124, NULL, '2020-06-13'),
(499, 13, 1, 107, NULL, '18/11/1978'),
(500, 13, 1, 111, 285, NULL),
(501, 13, 1, 144, NULL, '41'),
(502, 13, 1, 166, 45, NULL),
(503, 13, 1, 167, NULL, '2020-04-14'),
(505, 14, 2, 35, 298, NULL),
(506, 14, 2, 101, 306, NULL),
(507, 14, 2, 101, 305, NULL),
(508, 14, 2, 150, 300, NULL),
(509, 14, 2, 168, NULL, '2020-04-14'),
(510, 15, 3, 35, 298, NULL),
(511, 15, 3, 101, 305, NULL),
(512, 15, 3, 101, 306, NULL),
(513, 15, 3, 123, 276, NULL),
(514, 15, 3, 124, NULL, '2020-04-20'),
(515, 16, 1, 107, NULL, '17/02/1976'),
(516, 16, 1, 111, 285, NULL),
(517, 16, 1, 144, NULL, '44'),
(518, 16, 1, 166, 45, NULL),
(519, 16, 1, 167, NULL, '2020-04-15'),
(521, 17, 2, 150, 300, NULL),
(522, 17, 2, 168, NULL, '2020-04-15'),
(523, 18, 3, 123, 276, NULL),
(524, 18, 3, 124, NULL, '2020-04-18'),
(525, 28, 1, 107, NULL, '14/02/1952'),
(526, 28, 1, 111, 285, NULL),
(527, 28, 1, 144, NULL, '68'),
(528, 28, 1, 166, 45, NULL),
(529, 28, 1, 167, NULL, '2020-04-19'),
(531, 29, 2, 150, 300, NULL),
(532, 29, 2, 168, NULL, '2020-04-19'),
(533, 30, 3, 123, 276, NULL),
(534, 30, 3, 124, NULL, '2020-04-20'),
(535, 31, 1, 107, NULL, '30/10/1944'),
(536, 31, 1, 111, 284, NULL),
(537, 31, 1, 144, NULL, '75'),
(538, 31, 1, 166, 45, NULL),
(539, 31, 1, 167, NULL, '2020-04-20'),
(541, 32, 2, 35, 298, NULL),
(542, 32, 2, 101, 306, NULL),
(543, 32, 2, 101, 305, NULL),
(544, 32, 2, 150, 298, NULL),
(545, 32, 2, 168, NULL, '2020-04-20'),
(546, 32, 2, 228, NULL, '2020-04-20'),
(547, 33, 3, 35, 298, NULL),
(548, 33, 3, 101, 305, NULL),
(549, 33, 3, 101, 306, NULL),
(550, 33, 3, 123, 275, NULL),
(551, 33, 3, 124, NULL, '2020-04-30'),
(552, 34, 1, 107, NULL, '04/07/1975'),
(553, 34, 1, 111, 284, NULL),
(554, 34, 1, 144, NULL, '44'),
(555, 34, 1, 166, 45, NULL),
(556, 34, 1, 167, NULL, '2020-04-20'),
(558, 35, 2, 35, 298, NULL),
(559, 35, 2, 101, 305, NULL),
(560, 35, 2, 101, 306, NULL),
(561, 35, 2, 150, 300, NULL),
(562, 35, 2, 168, NULL, '2020-04-20'),
(563, 36, 3, 35, 298, NULL),
(564, 36, 3, 101, 306, NULL),
(565, 36, 3, 101, 305, NULL),
(566, 36, 3, 123, 276, NULL),
(567, 36, 3, 124, NULL, '2020-04-28'),
(568, 37, 1, 107, NULL, '09/12/1947'),
(569, 37, 1, 111, 284, NULL),
(570, 37, 1, 144, NULL, '72'),
(571, 37, 1, 166, 45, NULL),
(572, 37, 1, 167, NULL, '2020-04-21'),
(574, 38, 2, 35, 298, NULL),
(575, 38, 2, 101, 305, NULL),
(576, 38, 2, 101, 306, NULL),
(577, 38, 2, 150, 298, NULL),
(578, 38, 2, 168, NULL, '2020-04-21'),
(579, 38, 2, 228, NULL, '2020-04-21'),
(580, 39, 3, 35, 298, NULL),
(581, 39, 3, 101, 305, NULL),
(582, 39, 3, 101, 306, NULL),
(583, 39, 3, 123, 275, NULL),
(584, 39, 3, 124, NULL, '2020-05-08'),
(585, 43, 1, 107, NULL, '28/08/1936'),
(586, 43, 1, 111, 285, NULL),
(587, 43, 1, 144, NULL, '83'),
(588, 43, 1, 166, 45, NULL),
(589, 43, 1, 167, NULL, '2020-04-22'),
(591, 44, 2, 35, 298, NULL),
(592, 44, 2, 101, 306, NULL),
(593, 44, 2, 150, 300, NULL),
(594, 44, 2, 168, NULL, '2020-04-22'),
(595, 45, 3, 35, 298, NULL),
(596, 45, 3, 101, 306, NULL),
(597, 45, 3, 123, 276, NULL),
(598, 45, 3, 124, NULL, '2020-04-28'),
(599, 46, 1, 107, NULL, '03/09/1973'),
(600, 46, 1, 111, 284, NULL),
(601, 46, 1, 144, NULL, '46'),
(602, 46, 1, 166, 45, NULL),
(603, 46, 1, 167, NULL, '2020-04-23'),
(605, 47, 2, 35, 298, NULL),
(606, 47, 2, 101, 306, NULL),
(607, 47, 2, 101, 305, NULL),
(608, 47, 2, 150, 300, NULL),
(609, 47, 2, 168, NULL, '2020-04-23'),
(610, 48, 3, 35, 298, NULL),
(611, 48, 3, 101, 306, NULL),
(612, 48, 3, 101, 305, NULL),
(613, 48, 3, 123, 276, NULL),
(614, 48, 3, 124, NULL, '2020-04-27'),
(615, 49, 1, 107, NULL, '03/01/1973'),
(616, 49, 1, 111, 285, NULL),
(617, 49, 1, 144, NULL, '47'),
(618, 49, 1, 166, 45, NULL),
(619, 49, 1, 167, NULL, '2020-04-23'),
(621, 50, 2, 35, 298, NULL),
(622, 50, 2, 101, 306, NULL),
(623, 50, 2, 150, 300, NULL),
(624, 50, 2, 168, NULL, '2020-04-23'),
(625, 51, 3, 35, 298, NULL),
(626, 51, 3, 101, 306, NULL),
(627, 51, 3, 123, 276, NULL),
(628, 51, 3, 124, NULL, '2020-04-27'),
(629, 52, 1, 107, NULL, '27/01/1974'),
(630, 52, 1, 111, 285, NULL),
(631, 52, 1, 144, NULL, '46'),
(632, 52, 1, 166, 45, NULL),
(633, 52, 1, 167, NULL, '2020-04-23'),
(635, 53, 2, 35, 298, NULL),
(636, 53, 2, 101, 305, NULL),
(637, 53, 2, 101, 306, NULL),
(638, 53, 2, 150, 300, NULL),
(639, 53, 2, 168, NULL, '2020-04-23'),
(640, 54, 3, 35, 298, NULL),
(641, 54, 3, 101, 305, NULL),
(642, 54, 3, 101, 306, NULL),
(643, 54, 3, 123, 276, NULL),
(644, 54, 3, 124, NULL, '2020-05-08'),
(645, 58, 1, 107, NULL, '01/04/1964'),
(646, 58, 1, 111, 285, NULL),
(647, 58, 1, 144, NULL, '56'),
(648, 58, 1, 166, 45, NULL),
(649, 58, 1, 167, NULL, '2020-04-24'),
(651, 59, 2, 35, 298, NULL),
(652, 59, 2, 101, 305, NULL),
(653, 59, 2, 101, 306, NULL),
(654, 59, 2, 150, 300, NULL),
(655, 59, 2, 168, NULL, '2020-04-24'),
(656, 60, 3, 35, 298, NULL),
(657, 60, 3, 101, 305, NULL),
(658, 60, 3, 101, 306, NULL),
(659, 60, 3, 123, 276, NULL),
(660, 60, 3, 124, NULL, '2020-05-05'),
(661, 61, 1, 107, NULL, '05/06/1984'),
(662, 61, 1, 111, 284, NULL),
(663, 61, 1, 144, NULL, '36'),
(664, 61, 1, 166, 45, NULL),
(665, 61, 1, 167, NULL, '2020-04-26'),
(667, 62, 2, 35, 298, NULL),
(668, 62, 2, 101, 305, NULL),
(669, 62, 2, 150, 300, NULL),
(670, 62, 2, 168, NULL, '2020-04-26'),
(671, 63, 3, 35, 298, NULL),
(672, 63, 3, 101, 305, NULL),
(673, 63, 3, 123, 276, NULL),
(674, 63, 3, 124, NULL, '2020-01-05'),
(675, 70, 1, 107, NULL, '08/02/1979'),
(676, 70, 1, 111, 285, NULL),
(677, 70, 1, 144, NULL, '41'),
(678, 70, 1, 166, 45, NULL),
(679, 70, 1, 167, NULL, '2020-04-27'),
(681, 71, 2, 35, 298, NULL),
(682, 71, 2, 101, 306, NULL),
(683, 71, 2, 101, 305, NULL),
(684, 71, 2, 150, 300, NULL),
(685, 71, 2, 168, NULL, '2020-04-27'),
(686, 72, 3, 35, 298, NULL),
(687, 72, 3, 101, 305, NULL),
(688, 72, 3, 101, 306, NULL),
(689, 72, 3, 123, 276, NULL),
(690, 72, 3, 124, NULL, '2020-05-10'),
(691, 73, 1, 107, NULL, '03/03/1988'),
(692, 73, 1, 111, 285, NULL),
(693, 73, 1, 144, NULL, '32'),
(694, 73, 1, 166, 45, NULL),
(695, 73, 1, 167, NULL, '2020-04-28'),
(697, 74, 2, 35, 298, NULL),
(698, 74, 2, 101, 305, NULL),
(699, 74, 2, 101, 306, NULL),
(700, 74, 2, 150, 300, NULL),
(701, 74, 2, 168, NULL, '2020-04-28'),
(702, 75, 3, 35, 298, NULL),
(703, 75, 3, 101, 305, NULL),
(704, 75, 3, 101, 306, NULL),
(705, 75, 3, 123, 276, NULL),
(706, 75, 3, 124, NULL, '2020-03-05'),
(707, 76, 1, 107, NULL, '22/04/1960'),
(708, 76, 1, 111, 285, NULL),
(709, 76, 1, 144, NULL, '60'),
(710, 76, 1, 166, 45, NULL),
(711, 76, 1, 167, NULL, '2020-04-28'),
(713, 77, 2, 35, 298, NULL),
(714, 77, 2, 101, 306, NULL),
(715, 77, 2, 101, 305, NULL),
(716, 77, 2, 150, 298, NULL),
(717, 77, 2, 168, NULL, '2020-04-28'),
(718, 77, 2, 228, NULL, '2020-04-28'),
(719, 78, 3, 35, 298, NULL),
(720, 78, 3, 101, 305, NULL),
(721, 78, 3, 101, 306, NULL),
(722, 78, 3, 123, 275, NULL),
(723, 78, 3, 124, NULL, '2020-05-20'),
(724, 85, 1, 107, NULL, '10/12/1955'),
(725, 85, 1, 111, 285, NULL),
(726, 85, 1, 144, NULL, '64'),
(727, 85, 1, 166, 45, NULL),
(728, 85, 1, 167, NULL, '2020-01-05'),
(730, 86, 2, 35, 298, NULL),
(731, 86, 2, 101, 306, NULL),
(732, 86, 2, 150, 298, NULL),
(733, 86, 2, 168, NULL, '2020-01-05'),
(734, 86, 2, 228, NULL, '2020-01-05'),
(735, 87, 3, 35, 298, NULL),
(736, 87, 3, 101, 306, NULL),
(737, 87, 3, 123, 275, NULL),
(738, 87, 3, 124, NULL, '2020-03-05'),
(739, 88, 1, 107, NULL, '04/07/1951'),
(740, 88, 1, 111, 285, NULL),
(741, 88, 1, 144, NULL, '68'),
(742, 88, 1, 166, 45, NULL),
(743, 88, 1, 167, NULL, '2020-02-05'),
(745, 89, 2, 35, 298, NULL),
(746, 89, 2, 101, 306, NULL),
(747, 89, 2, 101, 305, NULL),
(748, 89, 2, 150, 298, NULL),
(749, 89, 2, 168, NULL, '2020-02-05'),
(750, 89, 2, 228, NULL, '2020-02-05'),
(751, 90, 3, 35, 298, NULL),
(752, 90, 3, 101, 306, NULL),
(753, 90, 3, 101, 305, NULL),
(754, 90, 3, 123, 275, NULL),
(755, 90, 3, 124, NULL, '2020-05-11'),
(756, 91, 1, 107, NULL, '12/09/1985'),
(757, 91, 1, 111, 285, NULL),
(758, 91, 1, 144, NULL, '34'),
(759, 91, 1, 166, 45, NULL),
(760, 91, 1, 167, NULL, '2020-02-05'),
(762, 92, 2, 35, 298, NULL),
(763, 92, 2, 101, 306, NULL),
(764, 92, 2, 150, 300, NULL),
(765, 92, 2, 168, NULL, '2020-02-05'),
(766, 93, 3, 35, 298, NULL),
(767, 93, 3, 101, 306, NULL),
(768, 93, 3, 123, 276, NULL),
(769, 93, 3, 124, NULL, '2020-04-05'),
(770, 100, 1, 107, NULL, '21/11/1961'),
(771, 100, 1, 111, 284, NULL),
(772, 100, 1, 144, NULL, '58'),
(773, 100, 1, 166, 45, NULL),
(774, 100, 1, 167, NULL, '2020-05-05'),
(776, 101, 2, 35, 298, NULL),
(777, 101, 2, 101, 306, NULL),
(778, 101, 2, 101, 305, NULL),
(779, 101, 2, 150, 298, NULL),
(780, 101, 2, 168, NULL, '2020-05-05'),
(781, 101, 2, 228, NULL, '2020-05-05'),
(782, 102, 3, 35, 298, NULL),
(783, 102, 3, 101, 306, NULL),
(784, 102, 3, 101, 305, NULL),
(785, 102, 3, 123, 275, NULL),
(786, 102, 3, 124, NULL, '2020-05-20'),
(787, 106, 1, 107, NULL, '18/09/1971'),
(788, 106, 1, 111, 284, NULL),
(789, 106, 1, 144, NULL, '48'),
(790, 106, 1, 166, 45, NULL),
(791, 106, 1, 167, NULL, '2020-05-06'),
(793, 107, 2, 150, 300, NULL),
(794, 107, 2, 168, NULL, '2020-05-06'),
(795, 108, 3, 123, 276, NULL),
(796, 108, 3, 124, NULL, '2020-05-12'),
(797, 124, 1, 107, NULL, '19/09/1995'),
(798, 124, 1, 111, 284, NULL),
(799, 124, 1, 144, NULL, '24'),
(800, 124, 1, 166, 45, NULL),
(801, 124, 1, 167, NULL, '2020-05-08'),
(803, 125, 2, 35, 298, NULL),
(804, 125, 2, 101, 305, NULL),
(805, 125, 2, 150, 300, NULL),
(806, 125, 2, 168, NULL, '2020-05-08'),
(807, 126, 3, 35, 298, NULL),
(808, 126, 3, 101, 305, NULL),
(809, 126, 3, 123, 276, NULL),
(810, 126, 3, 124, NULL, '2020-05-13'),
(811, 121, 1, 107, NULL, '14/09/1943'),
(812, 121, 1, 111, 285, NULL),
(813, 121, 1, 144, NULL, '76'),
(814, 121, 1, 166, 45, NULL),
(815, 121, 1, 167, NULL, '2020-05-08'),
(817, 122, 2, 35, 298, NULL),
(818, 122, 2, 101, 305, NULL),
(819, 122, 2, 150, 300, NULL),
(820, 122, 2, 168, NULL, '2020-05-08'),
(821, 123, 3, 35, 298, NULL),
(822, 123, 3, 101, 305, NULL),
(823, 123, 3, 123, 275, NULL),
(824, 123, 3, 124, NULL, '2020-05-17'),
(825, 127, 1, 107, NULL, '05/07/1974'),
(826, 127, 1, 111, 285, NULL),
(827, 127, 1, 144, NULL, '45'),
(828, 127, 1, 166, 45, NULL),
(829, 127, 1, 167, NULL, '2020-05-11'),
(831, 128, 2, 35, 298, NULL),
(832, 128, 2, 101, 305, NULL),
(833, 128, 2, 101, 306, NULL),
(834, 128, 2, 150, 300, NULL),
(835, 128, 2, 168, NULL, '2020-05-11'),
(836, 129, 3, 35, 298, NULL),
(837, 129, 3, 101, 306, NULL),
(838, 129, 3, 101, 305, NULL),
(839, 129, 3, 123, 276, NULL),
(840, 129, 3, 124, NULL, '2020-05-19'),
(841, 130, 1, 107, NULL, '10/02/1972'),
(842, 130, 1, 111, 284, NULL),
(843, 130, 1, 144, NULL, '48'),
(844, 130, 1, 166, 45, NULL),
(845, 130, 1, 167, NULL, '2020-05-12'),
(847, 131, 2, 35, 298, NULL),
(848, 131, 2, 101, 305, NULL),
(849, 131, 2, 150, 300, NULL),
(850, 131, 2, 168, NULL, '2020-05-12'),
(851, 132, 3, 35, 298, NULL),
(852, 132, 3, 101, 305, NULL),
(853, 132, 3, 123, 276, NULL),
(854, 132, 3, 124, NULL, '2020-05-19'),
(855, 133, 1, 107, NULL, '30/09/1966'),
(856, 133, 1, 111, 285, NULL),
(857, 133, 1, 144, NULL, '53'),
(858, 133, 1, 166, 45, NULL),
(859, 133, 1, 167, NULL, '2020-05-12'),
(861, 134, 2, 35, 298, NULL),
(862, 134, 2, 101, 305, NULL),
(863, 134, 2, 150, 298, NULL),
(864, 134, 2, 168, NULL, '2020-05-12'),
(865, 134, 2, 228, NULL, '2020-05-12'),
(866, 135, 3, 35, 298, NULL),
(867, 135, 3, 101, 305, NULL),
(868, 135, 3, 123, 275, NULL),
(869, 135, 3, 124, NULL, '2020-05-13'),
(870, 136, 1, 107, NULL, '21/08/1951'),
(871, 136, 1, 111, 284, NULL),
(872, 136, 1, 144, NULL, '68'),
(873, 136, 1, 166, 45, NULL),
(874, 136, 1, 167, NULL, '2020-05-12'),
(876, 137, 2, 35, 298, NULL),
(877, 137, 2, 101, 305, NULL),
(878, 137, 2, 150, 298, NULL),
(879, 137, 2, 168, NULL, '2020-05-12'),
(880, 137, 2, 228, NULL, '2020-05-12'),
(881, 138, 3, 35, 298, NULL),
(882, 138, 3, 101, 305, NULL),
(883, 138, 3, 123, 275, NULL),
(884, 138, 3, 124, NULL, '2020-06-12'),
(885, 139, 1, 107, NULL, '06/09/1951'),
(886, 139, 1, 111, 285, NULL),
(887, 139, 1, 144, NULL, '68'),
(888, 139, 1, 166, 45, NULL),
(889, 139, 1, 167, NULL, '2020-05-13'),
(891, 140, 2, 35, 298, NULL),
(892, 140, 2, 101, 305, NULL),
(893, 140, 2, 150, 300, NULL),
(894, 140, 2, 168, NULL, '2020-05-13'),
(895, 141, 3, 35, 298, NULL),
(896, 141, 3, 101, 305, NULL),
(897, 141, 3, 123, 276, NULL),
(898, 141, 3, 124, NULL, '2020-06-10'),
(899, 160, 1, 107, NULL, '16/03/1969'),
(900, 160, 1, 111, 285, NULL),
(901, 160, 1, 144, NULL, '51'),
(902, 160, 1, 166, 45, NULL),
(903, 160, 1, 167, NULL, '2020-05-14'),
(905, 161, 2, 150, 298, NULL),
(906, 161, 2, 168, NULL, '2020-05-14'),
(907, 161, 2, 228, NULL, '2020-05-14'),
(908, 162, 3, 123, 275, NULL),
(909, 162, 3, 124, NULL, '2020-05-21'),
(910, 157, 1, 107, NULL, '27/02/1968'),
(911, 157, 1, 111, 284, NULL),
(912, 157, 1, 144, NULL, '52'),
(913, 157, 1, 166, 45, NULL),
(914, 157, 1, 167, NULL, '2020-05-14'),
(916, 158, 2, 35, 298, NULL),
(917, 158, 2, 101, 305, NULL),
(918, 158, 2, 150, 300, NULL),
(919, 158, 2, 168, NULL, '2020-05-14'),
(920, 159, 3, 35, 298, NULL),
(921, 159, 3, 101, 305, NULL),
(922, 159, 3, 123, 276, NULL),
(923, 159, 3, 124, NULL, '2020-01-06'),
(924, 166, 1, 107, NULL, '23/08/1978'),
(925, 166, 1, 111, 285, NULL),
(926, 166, 1, 144, NULL, '41'),
(927, 166, 1, 166, 45, NULL),
(928, 166, 1, 167, NULL, '2020-05-15'),
(930, 167, 2, 150, 300, NULL),
(931, 167, 2, 168, NULL, '2020-05-15'),
(932, 168, 3, 123, 276, NULL),
(933, 168, 3, 124, NULL, '2020-05-20'),
(934, 163, 1, 107, NULL, '25/12/1964'),
(935, 163, 1, 111, 285, NULL),
(936, 163, 1, 144, NULL, '55'),
(937, 163, 1, 166, 45, NULL),
(938, 163, 1, 167, NULL, '2020-05-15'),
(940, 164, 2, 150, 300, NULL),
(941, 164, 2, 168, NULL, '2020-05-15'),
(942, 165, 3, 123, 276, NULL),
(943, 165, 3, 124, NULL, '2020-05-20'),
(944, 172, 1, 107, NULL, '17/03/1935'),
(945, 172, 1, 111, 284, NULL),
(946, 172, 1, 144, NULL, '85'),
(947, 172, 1, 166, 45, NULL),
(948, 172, 1, 167, NULL, '2020-05-18'),
(950, 173, 2, 35, 298, NULL),
(951, 173, 2, 101, 305, NULL),
(952, 173, 2, 150, 300, NULL),
(953, 173, 2, 168, NULL, '2020-05-18'),
(954, 174, 3, 35, 298, NULL),
(955, 174, 3, 101, 305, NULL),
(956, 174, 3, 123, 276, NULL),
(957, 174, 3, 124, NULL, '2020-05-27'),
(958, 175, 1, 107, NULL, '17/09/1984'),
(959, 175, 1, 111, 285, NULL),
(960, 175, 1, 144, NULL, '35'),
(961, 175, 1, 166, 45, NULL),
(962, 175, 1, 167, NULL, '2020-05-20'),
(964, 176, 2, 150, 300, NULL),
(965, 176, 2, 168, NULL, '2020-05-20'),
(966, 177, 3, 123, 276, NULL),
(967, 177, 3, 124, NULL, '2020-05-21'),
(968, 187, 1, 107, NULL, '17/09/1953'),
(969, 187, 1, 111, 284, NULL),
(970, 187, 1, 144, NULL, '66'),
(971, 187, 1, 166, 45, NULL),
(972, 187, 1, 167, NULL, '2020-05-21'),
(974, 188, 2, 150, 298, NULL),
(975, 188, 2, 168, NULL, '2020-05-21'),
(976, 188, 2, 228, NULL, '2020-05-21'),
(977, 189, 3, 123, 275, NULL),
(978, 189, 3, 124, NULL, '2020-04-06'),
(979, 178, 1, 107, NULL, '16/08/1952'),
(980, 178, 1, 111, 285, NULL),
(981, 178, 1, 144, NULL, '67'),
(982, 178, 1, 166, 45, NULL),
(983, 178, 1, 167, NULL, '2020-05-20'),
(985, 179, 2, 35, 298, NULL),
(986, 179, 2, 101, 305, NULL),
(987, 179, 2, 150, 300, NULL),
(988, 179, 2, 168, NULL, '2020-05-20'),
(989, 180, 3, 35, 298, NULL),
(990, 180, 3, 101, 305, NULL),
(991, 180, 3, 123, 276, NULL),
(992, 180, 3, 124, NULL, '2020-05-26'),
(993, 181, 1, 107, NULL, '18/08/1986'),
(994, 181, 1, 111, 285, NULL),
(995, 181, 1, 144, NULL, '33'),
(996, 181, 1, 166, 45, NULL),
(997, 181, 1, 167, NULL, '2020-05-20'),
(999, 182, 2, 35, 298, NULL),
(1000, 182, 2, 101, 305, NULL),
(1001, 182, 2, 101, 306, NULL),
(1002, 182, 2, 150, 300, NULL),
(1003, 182, 2, 168, NULL, '2020-05-20'),
(1004, 183, 3, 35, 298, NULL),
(1005, 183, 3, 101, 306, NULL),
(1006, 183, 3, 101, 305, NULL),
(1007, 183, 3, 123, 276, NULL),
(1008, 183, 3, 124, NULL, '2020-05-25'),
(1009, 190, 1, 107, NULL, '04/08/1960'),
(1010, 190, 1, 111, 285, NULL),
(1011, 190, 1, 144, NULL, '59'),
(1012, 190, 1, 166, 45, NULL),
(1013, 190, 1, 167, NULL, '2020-05-21'),
(1015, 191, 2, 35, 298, NULL),
(1016, 191, 2, 101, 305, NULL),
(1017, 191, 2, 150, 300, NULL),
(1018, 191, 2, 168, NULL, '2020-05-21'),
(1019, 192, 3, 35, 298, NULL),
(1020, 192, 3, 101, 305, NULL),
(1021, 192, 3, 123, 276, NULL),
(1022, 192, 3, 124, NULL, '2020-05-25'),
(1023, 199, 1, 107, NULL, '13/05/1954'),
(1024, 199, 1, 111, 284, NULL),
(1025, 199, 1, 144, NULL, '66'),
(1026, 199, 1, 166, 45, NULL),
(1027, 199, 1, 167, NULL, '2020-05-24'),
(1029, 200, 2, 35, 298, NULL),
(1030, 200, 2, 101, 305, NULL),
(1031, 200, 2, 150, 300, NULL),
(1032, 200, 2, 168, NULL, '2020-05-24'),
(1033, 201, 3, 35, 298, NULL),
(1034, 201, 3, 101, 305, NULL),
(1035, 201, 3, 123, 276, NULL),
(1036, 201, 3, 124, NULL, '2020-06-20'),
(1037, 205, 1, 107, NULL, '10/04/1961'),
(1038, 205, 1, 111, 285, NULL),
(1039, 205, 1, 144, NULL, '59'),
(1040, 205, 1, 166, 45, NULL),
(1041, 205, 1, 167, NULL, '2020-05-25'),
(1043, 206, 2, 35, 298, NULL),
(1044, 206, 2, 101, 305, NULL),
(1045, 206, 2, 150, 298, NULL),
(1046, 206, 2, 168, NULL, '2020-05-25'),
(1047, 206, 2, 228, NULL, '2020-05-25'),
(1048, 207, 3, 35, 298, NULL),
(1049, 207, 3, 101, 305, NULL),
(1050, 207, 3, 123, 275, NULL),
(1051, 207, 3, 124, NULL, '2020-02-06'),
(1052, 208, 1, 107, NULL, '10/10/1983'),
(1053, 208, 1, 111, 285, NULL),
(1054, 208, 1, 144, NULL, '36'),
(1055, 208, 1, 166, 45, NULL),
(1056, 208, 1, 167, NULL, '2020-05-26'),
(1058, 209, 2, 35, 298, NULL),
(1059, 209, 2, 101, 305, NULL),
(1060, 209, 2, 150, 300, NULL),
(1061, 209, 2, 168, NULL, '2020-05-26'),
(1062, 210, 3, 35, 298, NULL),
(1063, 210, 3, 101, 305, NULL),
(1064, 210, 3, 123, 276, NULL),
(1065, 210, 3, 124, NULL, '2020-05-06'),
(1066, 211, 1, 107, NULL, '06/01/1965'),
(1067, 211, 1, 111, 284, NULL),
(1068, 211, 1, 144, NULL, '55'),
(1069, 211, 1, 166, 45, NULL),
(1070, 211, 1, 167, NULL, '2020-05-29'),
(1072, 212, 2, 150, 300, NULL),
(1073, 212, 2, 168, NULL, '2020-05-29'),
(1074, 213, 3, 123, 276, NULL),
(1075, 213, 3, 124, NULL, '2020-04-06'),
(1076, 226, 1, 107, NULL, '14/04/1950'),
(1077, 226, 1, 111, 284, NULL),
(1078, 226, 1, 144, NULL, '70'),
(1079, 226, 1, 166, 45, NULL),
(1080, 226, 1, 167, NULL, '2020-06-12'),
(1082, 227, 2, 35, 298, NULL),
(1083, 227, 2, 101, 305, NULL),
(1084, 227, 2, 150, 300, NULL),
(1085, 227, 2, 168, NULL, '2020-06-12'),
(1086, 228, 3, 35, 298, NULL),
(1087, 228, 3, 101, 305, NULL),
(1088, 228, 3, 123, 276, NULL),
(1089, 228, 3, 124, NULL, '2020-06-16'),
(1090, 229, 1, 107, NULL, '22/10/1972'),
(1091, 229, 1, 111, 284, NULL),
(1092, 229, 1, 144, NULL, '47'),
(1093, 229, 1, 166, 45, NULL),
(1094, 229, 1, 167, NULL, '2020-06-12'),
(1096, 230, 2, 35, 298, NULL),
(1097, 230, 2, 101, 305, NULL),
(1098, 230, 2, 150, 300, NULL),
(1099, 230, 2, 168, NULL, '2020-06-12'),
(1100, 231, 3, 35, 298, NULL),
(1101, 231, 3, 101, 305, NULL),
(1102, 231, 3, 123, 276, NULL),
(1103, 231, 3, 124, NULL, '2020-06-17'),
(1104, 232, 1, 107, NULL, '10/09/1969'),
(1105, 232, 1, 111, 285, NULL),
(1106, 232, 1, 144, NULL, '50'),
(1107, 232, 1, 166, 45, NULL),
(1108, 232, 1, 167, NULL, '2020-06-15'),
(1110, 233, 2, 150, 298, NULL),
(1111, 233, 2, 168, NULL, '2020-06-15'),
(1112, 233, 2, 228, NULL, '2020-06-15'),
(1113, 234, 3, 123, 275, NULL),
(1114, 234, 3, 124, NULL, '2020-06-26'),
(1115, 235, 1, 107, NULL, '03/03/1936'),
(1116, 235, 1, 111, 284, NULL),
(1117, 235, 1, 144, NULL, '84'),
(1118, 235, 1, 166, 45, NULL),
(1119, 235, 1, 167, NULL, '2020-06-16'),
(1121, 236, 2, 35, 298, NULL),
(1122, 236, 2, 101, 305, NULL),
(1123, 236, 2, 150, 300, NULL),
(1124, 236, 2, 168, NULL, '2020-06-16'),
(1125, 237, 3, 35, 298, NULL),
(1126, 237, 3, 101, 305, NULL),
(1127, 237, 3, 123, 276, NULL),
(1128, 237, 3, 124, NULL, '2020-06-23'),
(6, 82, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(22, 220, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(37, 145, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(51, 193, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(65, 148, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(81, 10, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(98, 64, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(114, 55, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(130, 97, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(146, 94, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(171, 40, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(187, 202, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(201, 67, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(217, 103, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(227, 184, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(237, 25, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(253, 19, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(271, 196, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(285, 151, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(299, 214, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(313, 169, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(327, 118, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(343, 109, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(360, 142, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(374, 22, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(390, 217, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(404, 154, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(426, 112, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(440, 115, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(454, 79, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(470, 7, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(487, 223, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(504, 13, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(520, 16, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(530, 28, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(540, 31, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(557, 34, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(573, 37, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(590, 43, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(604, 46, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(620, 49, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(634, 52, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(650, 58, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(666, 61, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(680, 70, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(696, 73, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(712, 76, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(729, 85, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(744, 88, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(761, 91, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(775, 100, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(792, 106, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(802, 124, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(816, 121, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(830, 127, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(846, 130, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(860, 133, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(875, 136, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(890, 139, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(904, 160, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(915, 157, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(929, 166, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(939, 163, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(949, 172, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(963, 175, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(973, 187, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(984, 178, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(998, 181, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(1014, 190, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(1028, 199, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(1042, 205, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(1057, 208, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(1071, 211, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(1081, 226, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(1095, 229, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(1109, 232, 1, 242, NULL, 'HUGG - UNIDADE DE TERAPIA INTENSIVA – COVID A'),
(1120, 235, 1, 242, NULL, 'HUGG - ENFERMARIA – COVID'),
(1129, 238, 1, 167, NULL, '2020-12-08'),
(1130, 239, 2, 117, 296, ''),
(1131, 239, 2, 120, 298, ''),
(1132, 239, 2, 150, 298, ''),
(1133, 239, 2, 154, 296, ''),
(1134, 239, 2, 168, NULL, '2021-01-19'),
(1135, 239, 2, 217, NULL, '36'),
(1136, 240, 2, 33, 297, ''),
(1137, 240, 2, 39, 296, ''),
(1138, 240, 2, 152, 298, ''),
(1139, 240, 2, 168, NULL, '2020-04-22'),
(1140, 240, 2, 183, 298, ''),
(1141, 240, 2, 197, 298, ''),
(1142, 240, 2, 199, 298, ''),
(1143, 240, 2, 216, 9, ''),
(1144, 241, 2, 83, 296, ''),
(1145, 241, 2, 119, 296, ''),
(1146, 241, 2, 156, NULL, '123'),
(1147, 241, 2, 168, NULL, '2020-04-30'),
(1148, 241, 2, 177, 298, ''),
(1149, 241, 2, 183, 297, ''),
(1150, 241, 2, 184, 298, ''),
(1151, 241, 2, 185, 298, ''),
(1152, 241, 2, 218, 297, ''),
(1153, 241, 2, 220, 297, ''),
(1154, 241, 2, 241, 298, ''),
(1155, 241, 2, 250, 296, ''),
(1156, 241, 2, 251, 296, ''),
(1157, 242, 2, 35, 296, ''),
(1158, 242, 2, 36, 296, ''),
(1159, 242, 2, 119, 296, ''),
(1160, 242, 2, 155, 296, ''),
(1161, 242, 2, 168, NULL, '2021-02-03'),
(1162, 243, 2, 168, NULL, '2021-02-04'),
(1163, 244, 1, 166, 45, ''),
(1164, 244, 1, 167, NULL, '2021-02-15'),
(1165, 244, 1, 242, NULL, 'HUGG'),
(1166, 83, 2, 83, 296, ''),
(1167, 82, 1, 47, NULL, 'false'),
(1168, 82, 1, 49, NULL, 'true'),
(1169, 84, 3, 31, 296, ''),
(1170, 84, 3, 32, 296, ''),
(1171, 240, 2, 155, 296, ''),
(1172, 240, 2, 217, NULL, '37'),
(1173, 243, 2, 177, 298, ''),
(1174, 243, 2, 183, 296, ''),
(1175, 243, 2, 185, 298, ''),
(1176, 243, 2, 197, 296, ''),
(1177, 243, 2, 217, NULL, '37'),
(1178, 244, 1, 47, NULL, 'true'),
(1179, 244, 1, 49, NULL, 'true'),
(1180, 244, 1, 64, NULL, 'false'),
(1181, 240, 2, 149, 296, ''),
(1182, 240, 2, 151, 296, ''),
(1183, 240, 2, 153, 301, ''),
(1184, 240, 2, 154, 297, ''),
(1185, 240, 2, 218, 296, ''),
(1186, 240, 2, 220, 296, ''),
(1187, 82, 1, 54, 297, ''),
(1188, 82, 1, 55, 297, ''),
(1189, 82, 1, 59, 262, ''),
(1190, 82, 1, 63, NULL, 'true'),
(1191, 82, 1, 64, NULL, 'true'),
(1192, 55, 1, 47, NULL, 'false'),
(1193, 55, 1, 48, NULL, 'false'),
(1194, 55, 1, 49, NULL, 'false'),
(1195, 55, 1, 63, NULL, 'false'),
(1196, 55, 1, 64, NULL, 'true'),
(1197, 245, 2, 168, NULL, '2020-04-25'),
(1198, 245, 2, 217, NULL, '37'),
(1199, 245, 2, 218, 296, ''),
(1200, 245, 2, 220, 296, ''),
(1201, 55, 1, 203, 296, ''),
(1202, 55, 1, 204, 298, ''),
(1203, 246, 1, 49, NULL, 'true'),
(1204, 246, 1, 51, 297, ''),
(1205, 246, 1, 61, 296, ''),
(1206, 246, 1, 62, 296, ''),
(1207, 246, 1, 167, NULL, '2021-02-22'),
(1208, 246, 1, 202, 298, ''),
(1209, 246, 1, 203, 298, ''),
(1210, 246, 1, 129, 298, ''),
(1211, 246, 1, 134, 296, ''),
(1212, 246, 1, 137, 296, ''),
(1213, 246, 1, 140, 296, ''),
(1214, 246, 1, 209, 298, ''),
(1215, 246, 1, 214, 298, ''),
(1216, 246, 1, 252, 298, ''),
(1217, 246, 1, 253, 298, ''),
(1218, 247, 1, 53, 298, ''),
(1219, 247, 1, 54, 298, ''),
(1220, 247, 1, 95, 296, ''),
(1221, 247, 1, 130, 298, ''),
(1222, 247, 1, 152, 297, ''),
(1223, 247, 1, 153, 300, ''),
(1224, 247, 1, 154, 296, ''),
(1225, 247, 1, 167, NULL, '2021-01-14'),
(1226, 247, 1, 190, 7, ''),
(1227, 247, 1, 207, 297, ''),
(1228, 247, 1, 211, 296, ''),
(1229, 248, 1, 167, NULL, '2021-03-01'),
(1230, 249, 1, 52, 297, ''),
(1231, 249, 1, 60, 298, ''),
(1232, 249, 1, 108, 296, ''),
(1233, 249, 1, 109, 296, ''),
(1234, 249, 1, 167, NULL, '2020-12-24'),
(1235, 250, 2, 28, 297, ''),
(1236, 250, 2, 168, NULL, '2021-02-09'),
(1237, 250, 2, 187, 297, ''),
(1238, 251, 2, 168, NULL, '2020-03-16'),
(1239, 252, 2, 168, NULL, '2020-12-25'),
(1240, 253, 3, 124, NULL, '2021-03-01'),
(1241, 254, 1, 48, NULL, 'false'),
(1242, 254, 1, 63, NULL, 'false'),
(1243, 254, 1, 109, 298, ''),
(1244, 254, 1, 167, NULL, '2021-03-02'),
(1245, 255, 2, 168, NULL, '2021-03-02'),
(1246, 255, 2, 218, 296, ''),
(1247, 255, 2, 220, 296, ''),
(1248, 256, 2, 168, NULL, '2021-03-15T18:00'),
(1249, 257, 2, 168, NULL, '2021-04-28T17:32'),
(1250, 257, 2, 217, NULL, '43');

-- --------------------------------------------------------

--
-- Table structure for table `tb_questionnaire`
--

CREATE TABLE `tb_questionnaire` (
  `questionnaireID` int(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `questionnaireStatusID` int(10) DEFAULT NULL,
  `IsBasedOn` int(10) DEFAULT NULL,
  `createdBy` int(10) DEFAULT NULL,
  `version` varchar(50) DEFAULT NULL,
  `lastModification` timestamp NOT NULL DEFAULT current_timestamp(),
  `creationDate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_questionnaire`
--

INSERT INTO `tb_questionnaire` (`questionnaireID`, `description`, `questionnaireStatusID`, `IsBasedOn`, `createdBy`, `version`, `lastModification`, `creationDate`) VALUES
(1, 'WHO COVID-19 Rapid Version CRF', 1, NULL, NULL, '1.0', '2021-11-17 21:06:57', '2021-11-17 21:08:01'),
(2, 'Pesquisa de teste 2', 3, NULL, NULL, '0.0', '2021-11-17 23:16:07', '2021-11-19 22:21:11'),
(3, 'teste', 1, NULL, NULL, '0.0', '2021-11-24 00:23:05', '2021-11-24 00:23:05'),
(4, 'teste', 1, NULL, NULL, '0.0', '2021-11-24 00:23:05', '2021-11-24 00:23:05'),
(5, 'nova pesquisa', 1, NULL, NULL, '0.0', '2021-11-24 00:25:22', '2021-11-24 00:25:22'),
(6, 'Questionário 2', 2, NULL, NULL, '0.0', '2021-11-24 00:31:02', '2021-11-24 00:31:02'),
(7, 'textao', 2, NULL, NULL, '0.0', '2021-11-24 00:31:46', '2021-11-24 00:31:46'),
(8, 'Outra pesquisa', 2, NULL, NULL, '0.0', '2021-11-24 00:47:34', '2021-11-24 00:47:34');

-- --------------------------------------------------------

--
-- Table structure for table `tb_questionnaireparts`
--

CREATE TABLE `tb_questionnaireparts` (
  `questionnairePartsID` int(10) NOT NULL,
  `questionnairePartsTableID` int(10) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tb_questionnairepartsontology`
--

CREATE TABLE `tb_questionnairepartsontology` (
  `ontologyID` int(10) NOT NULL,
  `ontologyURI` varchar(255) NOT NULL,
  `questionnairePartsID` int(10) NOT NULL,
  `questionnairePartsTableID` int(10) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tb_questionnairepartstable`
--

CREATE TABLE `tb_questionnairepartstable` (
  `questionnairePartsTableID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tb_questionnairestatus`
--

CREATE TABLE `tb_questionnairestatus` (
  `questionnaireStatusID` int(19) NOT NULL,
  `description` varchar(255) NOT NULL,
  `creationDate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `tb_questionnairestatus`
--

INSERT INTO `tb_questionnairestatus` (`questionnaireStatusID`, `description`, `creationDate`) VALUES
(1, 'Published', '2021-11-19 20:56:01'),
(2, 'New', '2021-11-19 20:31:51'),
(3, 'Deprecated', '2021-11-19 20:31:58');

-- --------------------------------------------------------

--
-- Table structure for table `tb_questions`
--

CREATE TABLE `tb_questions` (
  `questionID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL COMMENT '(pt-br) Descrição.\r\n(en) description.',
  `questionTypeID` int(10) NOT NULL COMMENT '(pt-br) Chave estrangeira para tabela tb_QuestionsTypes.\r\n(en) Foreign key for the tp_QuestionsTypes table.',
  `listTypeID` int(10) DEFAULT NULL,
  `questionGroupID` int(10) DEFAULT NULL,
  `subordinateTo` int(10) DEFAULT NULL,
  `isAbout` int(10) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_questions`
--

INSERT INTO `tb_questions` (`questionID`, `description`, `questionTypeID`, `listTypeID`, `questionGroupID`, `subordinateTo`, `isAbout`) VALUES
(1, 'Age', 5, NULL, 6, NULL, NULL),
(2, 'Altered consciousness/confusion', 8, 15, NULL, NULL, NULL),
(3, 'Angiotensin converting enzyme inhibitors (ACE inhibitors)', 8, 15, NULL, NULL, NULL),
(4, 'Angiotensin II receptor blockers (ARBs)', 8, 15, NULL, NULL, NULL),
(5, 'AVPU scale', 4, 2, NULL, NULL, NULL),
(6, 'BP (diastolic)', 5, NULL, NULL, NULL, NULL),
(7, 'BP (systolic)', 5, NULL, NULL, NULL, NULL),
(8, 'Chest pain', 8, 15, NULL, NULL, NULL),
(9, 'Conjunctivitis', 8, 15, NULL, NULL, NULL),
(10, 'Cough', 8, 15, NULL, NULL, NULL),
(11, 'Cough with sputum', 8, 15, NULL, NULL, NULL),
(12, 'Diarrhoea', 8, 15, NULL, NULL, NULL),
(13, 'Glasgow Coma Score (GCS /15)', 5, NULL, NULL, NULL, NULL),
(14, 'Heart rate', 5, NULL, NULL, NULL, NULL),
(15, 'Muscle aches (myalgia)', 8, 15, NULL, NULL, NULL),
(16, 'Non-steroidal anti-inflammatory (NSAID)', 8, 15, NULL, NULL, NULL),
(17, 'Other signs or symptoms', 8, 15, NULL, NULL, NULL),
(18, 'Oxygen saturation', 5, NULL, NULL, NULL, NULL),
(19, 'Respiratory rate', 5, NULL, NULL, NULL, NULL),
(20, 'Seizures', 8, 15, NULL, NULL, NULL),
(21, 'Severe dehydration', 8, 15, NULL, NULL, NULL),
(22, 'Shortness of breath', 8, 15, NULL, NULL, NULL),
(23, 'Sore throat', 8, 15, NULL, NULL, NULL),
(24, 'Sternal capillary refill time >2seconds', 8, 15, NULL, NULL, NULL),
(25, 'Temperature', 5, NULL, NULL, NULL, NULL),
(26, 'Vomiting/Nausea', 8, 15, NULL, NULL, NULL),
(27, 'Which sign or symptom', 7, NULL, NULL, NULL, NULL),
(28, 'Other signs or symptoms', 8, 15, 4, NULL, 17),
(29, 'Other signs or symptoms', 8, 15, 12, NULL, 17),
(30, 'Other complication', 8, 15, 3, NULL, NULL),
(31, 'Chest X-Ray /CT performed', 8, 15, 7, NULL, NULL),
(32, 'Was pathogen testing done during this illness episode', 8, 15, 7, NULL, NULL),
(33, 'Antifungal agent', 8, 15, 9, NULL, NULL),
(34, 'Antimalarial agent', 8, 15, 9, NULL, NULL),
(35, 'Antiviral', 8, 15, 9, NULL, NULL),
(36, 'Corticosteroid', 8, 15, 9, NULL, NULL),
(37, 'Experimental agent', 8, 15, 9, NULL, NULL),
(38, 'Bleeding (Haemorrhage)', 8, 15, 12, NULL, NULL),
(39, 'Oxygen therapy', 8, 15, 13, NULL, NULL),
(40, 'Oxygen saturation', 5, NULL, 5, NULL, 18),
(41, 'Oxygen saturation', 5, NULL, 14, NULL, 18),
(42, 'Other respiratory pathogen', 6, 11, 7, 32, NULL),
(43, 'Viral haemorrhagic fever', 6, 11, 7, 32, NULL),
(44, 'Coronavirus', 6, 11, 7, 32, NULL),
(45, 'Which coronavirus', 4, 3, 7, 44, NULL),
(46, 'Influenza virus', 6, 11, 7, 32, NULL),
(47, 'A history of self-reported feverishness or measured fever of ≥ 38 degrees Celsius', 1, NULL, 1, NULL, NULL),
(48, 'Clinical suspicion of ARI despite not meeting criteria above', 1, NULL, 1, NULL, NULL),
(49, 'Proven or suspected infection with pathogen of Public Health Interest', 1, NULL, 1, NULL, NULL),
(50, 'Ashtma', 8, 15, 2, NULL, NULL),
(51, 'Asplenia', 8, 15, 2, NULL, NULL),
(52, 'Chronic cardiac disease (not hypertension)', 8, 15, 2, NULL, NULL),
(53, 'Chronic kidney disease', 8, 15, 2, NULL, NULL),
(54, 'Chronic liver disease', 8, 15, 2, NULL, NULL),
(55, 'Chronic neurological disorder', 8, 15, 2, NULL, NULL),
(56, 'Chronic pulmonary disease', 8, 15, 2, NULL, NULL),
(57, 'Current smoking', 8, 15, 2, NULL, NULL),
(58, 'Diabetes', 8, 15, 2, NULL, NULL),
(59, 'HIV', 4, 6, 2, NULL, NULL),
(60, 'Hypertension', 8, 15, 2, NULL, NULL),
(61, 'Malignant neoplasm', 8, 15, 2, NULL, NULL),
(62, 'Other co-morbidities', 8, 15, 2, NULL, NULL),
(63, 'Dyspnoea (shortness of breath) OR Tachypnoea', 1, NULL, 1, NULL, NULL),
(64, 'Cough', 1, NULL, 1, NULL, NULL),
(65, 'Tuberculosis', 8, 15, 2, NULL, NULL),
(66, 'Acute renal injury', 8, 15, 3, NULL, NULL),
(67, 'Acute Respiratory Distress Syndrome', 8, 15, 3, NULL, NULL),
(68, 'Anaemia', 8, 15, 3, NULL, NULL),
(69, 'Bacteraemia', 8, 15, 3, NULL, NULL),
(70, 'Bleeding', 8, 15, 3, NULL, NULL),
(71, 'Bronchiolitis', 8, 15, 3, NULL, NULL),
(72, 'Cardiac arrest', 8, 15, 3, NULL, NULL),
(73, 'Cardiac arrhythmia', 8, 15, 3, NULL, NULL),
(74, 'Cardiomyopathy', 8, 15, 3, NULL, NULL),
(75, 'Endocarditis', 8, 15, 3, NULL, NULL),
(76, 'Liver dysfunction', 8, 15, 3, NULL, NULL),
(77, 'Meningitis/Encephalitis', 8, 15, 3, NULL, NULL),
(78, 'Myocarditis/Pericarditis', 8, 15, 3, NULL, NULL),
(79, 'Pancreatitis', 8, 15, 3, NULL, NULL),
(80, 'Pneumonia', 8, 15, 3, NULL, NULL),
(81, 'Shock', 8, 15, 3, NULL, NULL),
(82, 'Which corticosteroid route', 4, 4, 9, 36, NULL),
(83, 'Confusion', 8, 15, 4, NULL, NULL),
(84, 'Falciparum malaria', 6, 11, 7, 32, NULL),
(85, 'HIV', 6, 11, 7, 32, NULL),
(86, 'Infiltrates present', 8, 15, 7, 31, NULL),
(87, 'Maximum daily corticosteroid dose', 7, NULL, 9, 36, NULL),
(88, 'Non-Falciparum malaria', 6, 11, 7, 32, NULL),
(89, 'O2 flow', 4, 8, 13, 39, NULL),
(90, 'Oxygen interface', 4, 7, 13, 39, NULL),
(91, 'Site name', 7, NULL, 12, 38, NULL),
(92, 'Source of oxygen', 4, 14, 13, 39, NULL),
(93, 'Admission date at this facility', 2, NULL, 5, NULL, NULL),
(94, 'Height', 5, NULL, 5, NULL, NULL),
(95, 'Malnutrition', 8, 15, 5, NULL, NULL),
(96, 'Mid-upper arm circumference', 5, NULL, 5, NULL, NULL),
(97, 'Symptom onset (date of first/earliest symptom)', 2, NULL, 5, NULL, NULL),
(98, 'Weight', 5, NULL, 5, NULL, NULL),
(99, 'Which antifungal agent', 7, NULL, 9, 33, NULL),
(100, 'Which antimalarial agent', 7, NULL, 9, 34, NULL),
(101, 'Which antiviral', 4, 1, 9, 35, NULL),
(102, 'Which complication', 7, NULL, 3, 30, NULL),
(103, 'Which experimental agent', 7, NULL, 9, 37, NULL),
(104, 'Which other antiviral', 7, NULL, 9, 35, NULL),
(105, 'Which other pathogen of public health interest detected', 7, NULL, 7, 32, NULL),
(106, 'Other corona virus', 7, NULL, 7, 44, NULL),
(107, 'Date of Birth', 2, NULL, 6, NULL, NULL),
(108, 'Healthcare worker', 8, 15, 6, NULL, NULL),
(109, 'Laboratory Worker', 8, 15, 6, NULL, NULL),
(110, 'Pregnant', 9, 16, 6, NULL, NULL),
(111, 'Sex at Birth', 4, 13, 6, NULL, NULL),
(112, 'Oxygen saturation expl', 4, 10, 14, 41, NULL),
(113, 'Gestational weeks assessment', 5, NULL, 6, 110, NULL),
(114, 'ALT/SGPT measurement', 3, NULL, 8, NULL, NULL),
(115, 'APTT/APTR measurement', 3, NULL, 8, NULL, NULL),
(116, 'AST/SGOT measurement', 3, NULL, 8, NULL, NULL),
(117, 'Antibiotic', 8, 15, 9, NULL, NULL),
(118, 'ESR measurement', 3, NULL, 8, NULL, NULL),
(119, 'Intravenous fluids', 8, 15, 9, NULL, NULL),
(120, 'Oral/orogastric fluids', 8, 15, 9, NULL, NULL),
(121, 'Influenza virus type', 7, NULL, 7, 46, NULL),
(122, 'Ability to self-care at discharge versus before illness', 4, 12, 10, NULL, NULL),
(123, 'Outcome', 4, 9, 10, NULL, NULL),
(124, 'Outcome date', 2, NULL, 10, NULL, NULL),
(125, 'Which respiratory pathogen', 7, NULL, 7, 42, NULL),
(126, 'Which virus', 7, NULL, 7, 43, NULL),
(127, 'Abdominal pain', 8, 15, 12, NULL, NULL),
(128, 'Cough with haemoptysis', 8, 15, 12, NULL, NULL),
(129, 'Fatigue/Malaise', 8, 15, 12, NULL, NULL),
(130, 'Headache', 8, 15, 12, NULL, NULL),
(131, 'duration in weeks', 5, NULL, NULL, NULL, NULL),
(132, 'History of fever', 8, 15, 12, NULL, NULL),
(133, 'Inability to walk', 8, 15, 12, NULL, NULL),
(134, 'Joint pain (arthralgia)', 8, 15, 12, NULL, NULL),
(135, 'Lower chest wall indrawing', 8, 15, 12, NULL, NULL),
(136, 'Lymphadenopathy', 8, 15, 12, NULL, NULL),
(137, 'Runny nose (rhinorrhoea)', 8, 15, 12, NULL, NULL),
(138, 'Skin rash', 8, 15, 12, NULL, NULL),
(139, 'Skin ulcers', 8, 15, 12, NULL, NULL),
(140, 'Wheezing', 8, 15, 12, NULL, NULL),
(141, 'Oxygen saturation expl', 4, 10, 5, 40, NULL),
(142, 'Which sign or symptom', 7, NULL, 4, 28, 27),
(143, 'Which sign or symptom', 7, NULL, 12, 29, 27),
(144, 'Age (years)', 5, NULL, 6, NULL, 1),
(145, 'Creatine kinase measurement', 3, NULL, 8, NULL, NULL),
(146, 'Creatinine measurement', 3, NULL, 8, NULL, NULL),
(147, 'CRP measurement', 3, NULL, 8, NULL, NULL),
(148, 'D-dimer measurement', 3, NULL, 8, NULL, NULL),
(149, 'Extracorporeal (ECMO) support', 8, 15, 13, NULL, NULL),
(150, 'ICU or High Dependency Unit admission', 8, 15, 13, NULL, NULL),
(151, 'Inotropes/vasopressors', 8, 15, 13, NULL, NULL),
(152, 'Invasive ventilation', 8, 15, 13, NULL, NULL),
(153, 'Non-invasive ventilation', 9, 16, 13, NULL, NULL),
(154, 'Prone position', 8, 15, 13, NULL, NULL),
(155, 'Renal replacement therapy (RRT) or dialysis', 8, 15, 13, NULL, NULL),
(156, 'Ferritin measurement', 3, NULL, 8, NULL, NULL),
(157, 'Haematocrit measurement', 3, NULL, 8, NULL, NULL),
(158, 'Haemoglobin measurement', 3, NULL, 8, NULL, NULL),
(159, 'IL-6 measurement', 3, NULL, 8, NULL, NULL),
(160, 'INR measurement', 3, NULL, 8, NULL, NULL),
(161, 'Lactate measurement', 3, NULL, 8, NULL, NULL),
(162, 'LDH measurement', 3, NULL, 8, NULL, NULL),
(163, 'Platelets measurement', 3, NULL, 8, NULL, NULL),
(164, 'Potassium measurement', 3, NULL, 8, NULL, NULL),
(165, 'Procalcitonin measurement', 3, NULL, 8, NULL, NULL),
(166, 'Country', 4, 5, NULL, NULL, NULL),
(167, 'Date of enrolment', 2, NULL, NULL, NULL, NULL),
(168, 'Date of follow up', 2, NULL, NULL, NULL, NULL),
(169, 'PT measurement', 3, NULL, 8, NULL, NULL),
(170, 'Sodium measurement', 3, NULL, 8, NULL, NULL),
(171, 'Total bilirubin measurement', 3, NULL, 8, NULL, NULL),
(172, 'Troponin measurement', 3, NULL, 8, NULL, NULL),
(173, 'duration in days', 5, NULL, NULL, NULL, NULL),
(174, 'Urea (BUN) measurement', 3, NULL, 8, NULL, NULL),
(175, 'specific response', 7, NULL, NULL, NULL, NULL),
(176, 'Seizures', 8, 15, 3, NULL, 20),
(177, 'Chest pain', 8, 15, 4, NULL, 8),
(178, 'Seizures', 8, 15, 4, NULL, 20),
(179, 'Altered consciousness/confusion', 8, 15, 4, NULL, 2),
(180, 'Which NSAID', 7, NULL, 9, 16, NULL),
(181, 'Oxygen saturation expl', 4, 10, NULL, NULL, NULL),
(182, 'Vomiting/Nausea', 8, 15, 4, NULL, 26),
(183, 'Cough', 8, 15, 4, NULL, 10),
(184, 'Sore throat', 8, 15, 4, NULL, 23),
(185, 'Shortness of breath', 8, 15, 4, NULL, 22),
(186, 'Diarrhoea', 8, 15, 4, NULL, 12),
(187, 'Muscle aches (myalgia)', 8, 15, 4, NULL, 15),
(188, 'Conjunctivitis', 8, 15, 4, NULL, 9),
(189, 'Severe dehydration', 8, 15, 5, NULL, 21),
(190, 'AVPU scale', 4, 2, 5, NULL, 5),
(191, 'Heart rate', 5, NULL, 5, NULL, 14),
(192, 'BP (diastolic)', 5, NULL, 5, NULL, 6),
(193, 'Glasgow Coma Score (GCS /15)', 5, NULL, 5, NULL, 13),
(194, 'Respiratory rate', 5, NULL, 5, NULL, 19),
(195, 'BP (systolic)', 5, NULL, 5, NULL, 7),
(196, 'Sternal capillary refill time >2seconds', 8, 15, 5, NULL, 24),
(197, 'Cough with sputum production', 8, 15, 4, NULL, 11),
(198, 'Temperature', 5, NULL, 5, NULL, 25),
(199, 'Non-steroidal anti-inflammatory (NSAID)', 8, 15, 9, NULL, 16),
(200, 'Angiotensin converting enzyme inhibitors (ACE inhibitors)', 8, 15, 9, NULL, 3),
(201, 'Angiotensin II receptor blockers (ARBs)', 8, 15, 9, NULL, 4),
(202, 'Angiotensin converting enzyme inhibitors (ACE inhibitors)', 8, 15, 11, NULL, 3),
(203, 'Angiotensin II receptor blockers (ARBs)', 8, 15, 11, NULL, 4),
(204, 'Non-steroidal anti-inflammatory (NSAID)', 8, 15, 11, NULL, 16),
(205, 'Shortness of breath', 8, 15, 12, NULL, 22),
(206, 'Vomiting/Nausea', 8, 15, 12, NULL, 26),
(207, 'Altered consciousness/confusion', 8, 15, 12, NULL, 2),
(208, 'Diarrhoea', 8, 15, 12, NULL, 12),
(209, 'Muscle aches (myalgia)', 8, 15, 12, NULL, 15),
(210, 'Cough', 8, 15, 12, NULL, 10),
(211, 'Seizures', 8, 15, 12, NULL, 20),
(212, 'Age (months)', 5, NULL, 6, NULL, 1),
(213, 'Conjunctivitis', 8, 15, 12, NULL, 9),
(214, 'Chest pain', 8, 15, 12, NULL, 8),
(215, 'Sore throat', 8, 15, 12, NULL, 23),
(216, 'AVPU scale', 4, 2, 14, NULL, 5),
(217, 'Temperature', 5, NULL, 14, NULL, 25),
(218, 'Sternal capillary refill time >2seconds', 8, 15, 14, NULL, 24),
(219, 'BP (diastolic)', 5, NULL, 14, NULL, 6),
(220, 'Severe dehydration', 8, 15, 14, NULL, 21),
(221, 'Heart rate', 5, NULL, 14, NULL, 14),
(222, 'BP (systolic)', 5, NULL, 14, NULL, 7),
(223, 'Glasgow Coma Score (GCS /15)', 5, NULL, 14, NULL, 13),
(224, 'Respiratory rate', 5, NULL, 14, NULL, 19),
(225, 'Cough with sputum production', 8, 15, 12, NULL, 11),
(226, 'WBC count measurement', 3, NULL, 8, NULL, NULL),
(227, 'Which other co-morbidities', 7, NULL, 2, 62, NULL),
(228, 'Date of ICU/HDU admission', 2, NULL, 13, 150, NULL),
(229, 'ICU/HDU discharge date', 2, NULL, 13, 150, NULL),
(230, 'Date of ICU/HDU admission', 2, NULL, 13, 150, NULL),
(231, 'ICU/HDU discharge date', 2, NULL, 13, 150, NULL),
(232, 'Which antibiotic', 7, NULL, 9, 117, NULL),
(233, 'Total duration ICU/HCU', 5, NULL, 13, 150, 173),
(234, 'Total duration Oxygen Therapy', 5, NULL, 13, 39, 173),
(235, 'Total duration Non-invasive ventilation', 5, NULL, 13, 153, 173),
(236, 'Total duration Invasive ventilation', 5, NULL, 13, 152, 173),
(237, 'Total duration ECMO', 5, NULL, 13, 149, 173),
(238, 'Total duration Prone position', 5, NULL, 13, 154, 173),
(239, 'Total duration RRT or dyalysis', 5, NULL, 13, 155, 173),
(240, 'Total duration Inotropes/vasopressors', 5, NULL, 13, 151, 173),
(241, 'Systemic anticoagulation', 8, 15, 9, NULL, NULL),
(242, 'Facility name', 7, NULL, NULL, NULL, NULL),
(243, 'Loss of smell', 8, 15, NULL, NULL, NULL),
(244, 'Loss of taste', 8, 15, NULL, NULL, NULL),
(245, 'FiO2 value', 10, NULL, 13, 152, NULL),
(246, 'PaO2 value', 10, NULL, 13, 152, NULL),
(247, 'PaCO2 value', 10, NULL, 13, 152, NULL),
(248, 'Plateau pressure value', 10, NULL, 13, 152, NULL),
(249, 'PEEP value', 10, NULL, 13, 152, NULL),
(250, 'Loss of smell daily', 8, 15, 4, NULL, 243),
(251, 'Loss of taste daily', 8, 15, 4, NULL, 244),
(252, 'Loss of smell signs', 8, 15, 12, NULL, 243),
(253, 'Loss of taste signs', 8, 15, 12, NULL, 244),
(254, 'Which antiviral', 4, 1, 11, NULL, 101),
(255, 'Which other antiviral', 7, NULL, 11, 254, 104);

-- --------------------------------------------------------

--
-- Table structure for table `tb_questiontype`
--

CREATE TABLE `tb_questiontype` (
  `questionTypeID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL COMMENT '(pt-br) Descrição.\r\n(en) description.'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_questiontype`
--

INSERT INTO `tb_questiontype` (`questionTypeID`, `description`) VALUES
(1, 'Boolean_Question'),
(2, 'Date question'),
(3, 'Laboratory question'),
(4, 'List question'),
(5, 'Number question'),
(6, 'PNNot_done_Question'),
(7, 'Text_Question'),
(8, 'YNU_Question'),
(9, 'YNUN_Question'),
(10, 'Ventilation question');

-- --------------------------------------------------------

--
-- Table structure for table `tb_user`
--

CREATE TABLE `tb_user` (
  `userID` bigint(20) UNSIGNED NOT NULL,
  `login` varchar(255) NOT NULL,
  `firstName` varchar(100) NOT NULL,
  `lastName` varchar(100) NOT NULL,
  `regionalCouncilCode` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `eMail` varchar(255) DEFAULT NULL,
  `foneNumber` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_user`
--

INSERT INTO `tb_user` (`userID`, `login`, `firstName`, `lastName`, `regionalCouncilCode`, `password`, `eMail`, `foneNumber`) VALUES
(2, 'ETL_Hosp_Exemplo', 'ETL', 'Hosp EXEMPLO', NULL, 'testepsw', 'admin@hospitalexemplo.com.br', '5555-5555'),
(3, '01482642719', 'Vania', 'Borges', 'CRM 69596800', 'teste_psw', 'vj@gmail.com', '21 5555-5555'),
(4, 'teste', 'first', 'last', 'CRF 00-852-26', 'teste', 'teste@gmail.com', '5555-5555'),
(5, 'teste2', 'first2', 'last2', 'CRF 00-852-27', 'teste2', 'teste2@gmail.com', '5555-5555'),
(6, 'teste3', 'first3', 'last3', 'CRF 00-852-23', 'teste_3', 'teste3_@gmail.com', '5555-5553'),
(7, 'teste4', 'first4', 'last4', 'CRF 00-852-24', 'teste_4', 'teste4_@gmail.com', '5555-5554'),
(8, 'Admin HUGG', 'Administrador', 'HUGG', 'CRM/CRF', 'teste_psw', 'adminHUGG@gmail.com', '21 5555-5555'),
(9, 'Teste5', 'first5', 'last5', 'CRF_teste5', 'teste5_psw', 'teste5@gmail.com', '21 5555-5555'),
(11, 'Admin', 'Administrador', 'Sistema', 'CRM/CRF', '7ysrK58rK/krKzwrK0MrKw==', 'adminsys@gmail.com', '5555-5555'),
(13, 'teste11@email.com', 'Teste11', 'teste11', '123', '123456', 'teste11@email.com', '12345678'),
(14, 'user@email.com', 'user', 'teste', '123456', '123456', 'user@email.com', '912345678'),
(15, 'rodrigo@gmail.com', 'Rodrigo', 'Araújo', '123456', '123456', 'rodrigo@gmail.com', '911111111'),
(18, 'nome@email.com', 'Nome', 'Sobrenome', '123456', 'BcdnZyNnZ8NnZxhnZ5ZnZw==', 'nome@email.com', '123456789'),
(19, 'novousuario@email.com', 'NovoUsuário', 'Sobrenome', '6698877553', 'xwVnZ5ZnZxhnZ8NnZyNnZw==', 'novousuario@email.com', '21369987751'),
(20, 'maya@gmail.com', 'Maya', 'Morais', '32434234', '7ysrK58rK/krKzwrK0MrKw==', 'maya@gmail.com', '2199999999'),
(21, 'shrek@gmail.com', 'Shrek', 'Fione', '12345466', 'xwVnZ5ZnZxhnZ8NnZyNnZw==', 'shrek@gmail.com', '219999999'),
(22, 'mayamoraiss@gmail.com', 'Fiona', 'Shrek', '2344242344', 'xwVnZ5ZnZxhnZ8NnZyNnZw==', 'mayamoraiss@gmail.com', '2199999999');

-- --------------------------------------------------------

--
-- Table structure for table `tb_userrole`
--

CREATE TABLE `tb_userrole` (
  `userID` int(11) NOT NULL,
  `groupRoleID` int(11) NOT NULL,
  `hospitalUnitID` int(11) NOT NULL,
  `creationDate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `expirationDate` timestamp NULL DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_userrole`
--

INSERT INTO `tb_userrole` (`userID`, `groupRoleID`, `hospitalUnitID`, `creationDate`, `expirationDate`) VALUES
(5, 7, 1, '2020-12-07 14:07:15', NULL),
(6, 7, 1, '2020-12-07 14:33:12', NULL),
(7, 7, 1, '2020-12-07 14:35:32', NULL),
(3, 7, 1, '2020-12-07 14:44:23', NULL),
(5, 7, 2, '2020-12-07 14:47:02', NULL),
(8, 1, 1, '2020-12-09 18:43:06', NULL),
(9, 7, 1, '2020-12-09 19:05:04', NULL),
(11, 1, 1, '2020-12-09 20:11:59', NULL),
(11, 1, 2, '2020-12-09 20:11:59', NULL),
(12, 6, 1, '2021-02-08 18:07:18', NULL),
(13, 6, 1, '2021-02-08 18:10:27', NULL),
(14, 7, 1, '2021-02-08 18:13:05', NULL),
(15, 6, 1, '2021-02-08 19:39:51', NULL),
(16, 6, 1, '2021-03-16 18:06:42', NULL),
(17, 6, 1, '2021-03-16 18:20:12', NULL),
(18, 6, 1, '2021-03-16 18:24:26', NULL),
(19, 6, 1, '2021-04-30 18:24:42', NULL),
(20, 1, 1, '2021-10-12 21:24:24', NULL),
(21, 7, 1, '2021-10-15 08:33:36', NULL),
(22, 6, 1, '2021-10-15 08:34:34', NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_crfforms_covidcrfrapid`
-- (See below for the actual view)
--
CREATE TABLE `vw_crfforms_covidcrfrapid` (
`crfFormsID` int(10)
,`questionnaireID` int(10)
,`description` varchar(255)
,`ontologyURI` varchar(500)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_listofvalues_covidcrfrapid`
-- (See below for the actual view)
--
CREATE TABLE `vw_listofvalues_covidcrfrapid` (
`listOfValuesID` int(10)
,`listTypeID` int(10)
,`description` varchar(255)
,`ontologyURI` varchar(500)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_listype_covidcrfrapid`
-- (See below for the actual view)
--
CREATE TABLE `vw_listype_covidcrfrapid` (
`listTypeID` int(10)
,`description` varchar(255)
,`ontologyURI` varchar(500)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_questiongroupform_covidcrfrapid`
-- (See below for the actual view)
--
CREATE TABLE `vw_questiongroupform_covidcrfrapid` (
`crfFormsID` int(10)
,`questionID` int(10)
,`questionOrder` int(10)
,`form_OntologyURI` varchar(500)
,`question_OntologyURI` varchar(500)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_questiongroup_covidcrfrapid`
-- (See below for the actual view)
--
CREATE TABLE `vw_questiongroup_covidcrfrapid` (
`questionGroupID` int(10)
,`description` varchar(255)
,`comment` varchar(255)
,`ontologyURI` varchar(500)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_questionnaire_covidcrfrapid`
-- (See below for the actual view)
--
CREATE TABLE `vw_questionnaire_covidcrfrapid` (
`questionnaireID` int(255)
,`description` varchar(255)
,`ontologyURI` varchar(500)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_questions_covidcrfrapid`
-- (See below for the actual view)
--
CREATE TABLE `vw_questions_covidcrfrapid` (
`questionID` int(10)
,`description` varchar(255)
,`questionTypeID` int(10)
,`listTypeID` int(10)
,`questionGroupID` int(10)
,`subordinateTo` int(10)
,`isAbout` int(10)
,`ontologyURI` varchar(500)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_questiontype_covidcrfrapid`
-- (See below for the actual view)
--
CREATE TABLE `vw_questiontype_covidcrfrapid` (
`questionTypeID` int(10)
,`description` varchar(255)
,`ontologyURI` varchar(500)
);

-- --------------------------------------------------------

--
-- Structure for view `vw_crfforms_covidcrfrapid`
--
DROP TABLE IF EXISTS `vw_crfforms_covidcrfrapid`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_crfforms_covidcrfrapid`  AS SELECT `t1`.`crfFormsID` AS `crfFormsID`, `t1`.`questionnaireID` AS `questionnaireID`, `t1`.`description` AS `description`, `ontologyURI`('COVIDCRFRAPID','tb_crfforms',`t1`.`crfFormsID`) AS `ontologyURI` FROM `tb_crfforms` AS `t1` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_listofvalues_covidcrfrapid`
--
DROP TABLE IF EXISTS `vw_listofvalues_covidcrfrapid`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_listofvalues_covidcrfrapid`  AS SELECT `t1`.`listOfValuesID` AS `listOfValuesID`, `t1`.`listTypeID` AS `listTypeID`, `t1`.`description` AS `description`, `ontologyURI`('COVIDCRFRAPID','tb_listofvalues',`t1`.`listOfValuesID`) AS `ontologyURI` FROM `tb_listofvalues` AS `t1` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_listype_covidcrfrapid`
--
DROP TABLE IF EXISTS `vw_listype_covidcrfrapid`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_listype_covidcrfrapid`  AS SELECT `t1`.`listTypeID` AS `listTypeID`, `t1`.`description` AS `description`, `ontologyURI`('COVIDCRFRAPID','tb_listtype',`t1`.`listTypeID`) AS `ontologyURI` FROM `tb_listtype` AS `t1` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_questiongroupform_covidcrfrapid`
--
DROP TABLE IF EXISTS `vw_questiongroupform_covidcrfrapid`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_questiongroupform_covidcrfrapid`  AS SELECT `t1`.`crfFormsID` AS `crfFormsID`, `t1`.`questionID` AS `questionID`, `t1`.`questionOrder` AS `questionOrder`, `t2`.`ontologyURI` AS `form_OntologyURI`, `t3`.`ontologyURI` AS `question_OntologyURI` FROM ((`tb_questiongroupform` `t1` join `vw_crfforms_covidcrfrapid` `t2`) join `vw_questions_covidcrfrapid` `t3`) WHERE `t2`.`crfFormsID` = `t1`.`crfFormsID` AND `t3`.`questionID` = `t1`.`questionID` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_questiongroup_covidcrfrapid`
--
DROP TABLE IF EXISTS `vw_questiongroup_covidcrfrapid`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_questiongroup_covidcrfrapid`  AS SELECT `t1`.`questionGroupID` AS `questionGroupID`, `t1`.`description` AS `description`, `t1`.`comment` AS `comment`, `ontologyURI`('COVIDCRFRAPID','tb_questiongroup',`t1`.`questionGroupID`) AS `ontologyURI` FROM `tb_questiongroup` AS `t1` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_questionnaire_covidcrfrapid`
--
DROP TABLE IF EXISTS `vw_questionnaire_covidcrfrapid`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_questionnaire_covidcrfrapid`  AS SELECT `t1`.`questionnaireID` AS `questionnaireID`, `t1`.`description` AS `description`, `ontologyURI`('COVIDCRFRAPID','tb_questionnaire',`t1`.`questionnaireID`) AS `ontologyURI` FROM `tb_questionnaire` AS `t1` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_questions_covidcrfrapid`
--
DROP TABLE IF EXISTS `vw_questions_covidcrfrapid`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_questions_covidcrfrapid`  AS SELECT `t1`.`questionID` AS `questionID`, `t1`.`description` AS `description`, `t1`.`questionTypeID` AS `questionTypeID`, `t1`.`listTypeID` AS `listTypeID`, `t1`.`questionGroupID` AS `questionGroupID`, `t1`.`subordinateTo` AS `subordinateTo`, `t1`.`isAbout` AS `isAbout`, `ontologyURI`('COVIDCRFRAPID','tb_questions',`t1`.`questionID`) AS `ontologyURI` FROM `tb_questions` AS `t1` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_questiontype_covidcrfrapid`
--
DROP TABLE IF EXISTS `vw_questiontype_covidcrfrapid`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_questiontype_covidcrfrapid`  AS SELECT `t1`.`questionTypeID` AS `questionTypeID`, `t1`.`description` AS `description`, `ontologyURI`('COVIDCRFRAPID','tb_questiontype',`t1`.`questionTypeID`) AS `ontologyURI` FROM `tb_questiontype` AS `t1` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tb_assessmentquestionnaire`
--
ALTER TABLE `tb_assessmentquestionnaire`
  ADD PRIMARY KEY (`participantID`,`hospitalUnitID`,`questionnaireID`),
  ADD KEY `FKtb_Assessm665217` (`hospitalUnitID`),
  ADD KEY `FKtb_Assessm419169` (`questionnaireID`);

--
-- Indexes for table `tb_crfforms`
--
ALTER TABLE `tb_crfforms`
  ADD PRIMARY KEY (`crfFormsID`),
  ADD KEY `FKtb_CRFForm860269` (`questionnaireID`),
  ADD KEY `crfformsStatusID` (`crfformsStatusID`);

--
-- Indexes for table `tb_crfformsstatus`
--
ALTER TABLE `tb_crfformsstatus`
  ADD PRIMARY KEY (`crfformsStatusID`);

--
-- Indexes for table `tb_formrecord`
--
ALTER TABLE `tb_formrecord`
  ADD PRIMARY KEY (`formRecordID`),
  ADD KEY `FKtb_FormRec2192` (`crfFormsID`),
  ADD KEY `FKtb_FormRec984256` (`participantID`,`hospitalUnitID`,`questionnaireID`);

--
-- Indexes for table `tb_grouprole`
--
ALTER TABLE `tb_grouprole`
  ADD PRIMARY KEY (`groupRoleID`),
  ADD UNIQUE KEY `groupRoleID` (`groupRoleID`);

--
-- Indexes for table `tb_grouprolepermission`
--
ALTER TABLE `tb_grouprolepermission`
  ADD PRIMARY KEY (`groupRoleID`,`permissionID`),
  ADD KEY `FKtb_GroupRo893005` (`permissionID`);

--
-- Indexes for table `tb_hospitalunit`
--
ALTER TABLE `tb_hospitalunit`
  ADD PRIMARY KEY (`hospitalUnitID`);

--
-- Indexes for table `tb_language`
--
ALTER TABLE `tb_language`
  ADD PRIMARY KEY (`languageID`);

--
-- Indexes for table `tb_listofvalues`
--
ALTER TABLE `tb_listofvalues`
  ADD PRIMARY KEY (`listOfValuesID`),
  ADD KEY `FKtb_ListOfV184108` (`listTypeID`);

--
-- Indexes for table `tb_listtype`
--
ALTER TABLE `tb_listtype`
  ADD PRIMARY KEY (`listTypeID`);

--
-- Indexes for table `tb_multilanguage`
--
ALTER TABLE `tb_multilanguage`
  ADD PRIMARY KEY (`languageID`,`description`);

--
-- Indexes for table `tb_notificationrecord`
--
ALTER TABLE `tb_notificationrecord`
  ADD PRIMARY KEY (`userID`,`profileID`,`hospitalUnitID`,`tableName`,`rowdID`,`changedOn`,`operation`);

--
-- Indexes for table `tb_ontology`
--
ALTER TABLE `tb_ontology`
  ADD PRIMARY KEY (`ontologyID`);

--
-- Indexes for table `tb_ontologyterms`
--
ALTER TABLE `tb_ontologyterms`
  ADD PRIMARY KEY (`ontologyURI`,`ontologyID`),
  ADD KEY `FKtb_Ontolog722236` (`ontologyID`);

--
-- Indexes for table `tb_participant`
--
ALTER TABLE `tb_participant`
  ADD PRIMARY KEY (`participantID`);

--
-- Indexes for table `tb_permission`
--
ALTER TABLE `tb_permission`
  ADD PRIMARY KEY (`permissionID`),
  ADD UNIQUE KEY `permissionID` (`permissionID`);

--
-- Indexes for table `tb_questiongroup`
--
ALTER TABLE `tb_questiongroup`
  ADD PRIMARY KEY (`questionGroupID`);

--
-- Indexes for table `tb_questiongroupform`
--
ALTER TABLE `tb_questiongroupform`
  ADD PRIMARY KEY (`crfFormsID`,`questionID`),
  ADD KEY `FKtb_Questio124287` (`questionID`);

--
-- Indexes for table `tb_questiongroupformrecord`
--
ALTER TABLE `tb_questiongroupformrecord`
  ADD PRIMARY KEY (`questionGroupFormRecordID`),
  ADD KEY `FKtb_Questio928457` (`listOfValuesID`),
  ADD KEY `FKtb_Questio489549` (`crfFormsID`,`questionID`),
  ADD KEY `FKtb_Questio935723` (`formRecordID`);

--
-- Indexes for table `tb_questionnaire`
--
ALTER TABLE `tb_questionnaire`
  ADD PRIMARY KEY (`questionnaireID`);

--
-- Indexes for table `tb_questionnaireparts`
--
ALTER TABLE `tb_questionnaireparts`
  ADD PRIMARY KEY (`questionnairePartsID`,`questionnairePartsTableID`),
  ADD KEY `FKtb_Questio42774` (`questionnairePartsTableID`);

--
-- Indexes for table `tb_questionnairepartsontology`
--
ALTER TABLE `tb_questionnairepartsontology`
  ADD PRIMARY KEY (`ontologyID`,`ontologyURI`,`questionnairePartsID`,`questionnairePartsTableID`),
  ADD KEY `FKtb_Questio546464` (`ontologyURI`,`ontologyID`),
  ADD KEY `FKtb_Questio773521` (`questionnairePartsID`,`questionnairePartsTableID`);

--
-- Indexes for table `tb_questionnairepartstable`
--
ALTER TABLE `tb_questionnairepartstable`
  ADD PRIMARY KEY (`questionnairePartsTableID`);

--
-- Indexes for table `tb_questionnairestatus`
--
ALTER TABLE `tb_questionnairestatus`
  ADD PRIMARY KEY (`questionnaireStatusID`);

--
-- Indexes for table `tb_questions`
--
ALTER TABLE `tb_questions`
  ADD PRIMARY KEY (`questionID`),
  ADD KEY `FKtb_Questio240796` (`listTypeID`),
  ADD KEY `FKtb_Questio684913` (`questionTypeID`),
  ADD KEY `FKtb_Questio808495` (`questionGroupID`),
  ADD KEY `SubordinateTo` (`subordinateTo`),
  ADD KEY `isAbout` (`isAbout`);

--
-- Indexes for table `tb_questiontype`
--
ALTER TABLE `tb_questiontype`
  ADD PRIMARY KEY (`questionTypeID`);

--
-- Indexes for table `tb_user`
--
ALTER TABLE `tb_user`
  ADD PRIMARY KEY (`userID`),
  ADD UNIQUE KEY `userID` (`userID`),
  ADD UNIQUE KEY `login` (`login`);

--
-- Indexes for table `tb_userrole`
--
ALTER TABLE `tb_userrole`
  ADD PRIMARY KEY (`userID`,`groupRoleID`,`hospitalUnitID`),
  ADD KEY `FKtb_UserRol864770` (`groupRoleID`),
  ADD KEY `FKtb_UserRol324331` (`hospitalUnitID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tb_crfforms`
--
ALTER TABLE `tb_crfforms`
  MODIFY `crfFormsID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tb_formrecord`
--
ALTER TABLE `tb_formrecord`
  MODIFY `formRecordID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=258;

--
-- AUTO_INCREMENT for table `tb_grouprole`
--
ALTER TABLE `tb_grouprole`
  MODIFY `groupRoleID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `tb_hospitalunit`
--
ALTER TABLE `tb_hospitalunit`
  MODIFY `hospitalUnitID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `tb_language`
--
ALTER TABLE `tb_language`
  MODIFY `languageID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tb_listofvalues`
--
ALTER TABLE `tb_listofvalues`
  MODIFY `listOfValuesID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=308;

--
-- AUTO_INCREMENT for table `tb_listtype`
--
ALTER TABLE `tb_listtype`
  MODIFY `listTypeID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `tb_ontology`
--
ALTER TABLE `tb_ontology`
  MODIFY `ontologyID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tb_participant`
--
ALTER TABLE `tb_participant`
  MODIFY `participantID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=186;

--
-- AUTO_INCREMENT for table `tb_permission`
--
ALTER TABLE `tb_permission`
  MODIFY `permissionID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `tb_questiongroup`
--
ALTER TABLE `tb_questiongroup`
  MODIFY `questionGroupID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `tb_questiongroupformrecord`
--
ALTER TABLE `tb_questiongroupformrecord`
  MODIFY `questionGroupFormRecordID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1251;

--
-- AUTO_INCREMENT for table `tb_questionnaire`
--
ALTER TABLE `tb_questionnaire`
  MODIFY `questionnaireID` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `tb_questionnairepartstable`
--
ALTER TABLE `tb_questionnairepartstable`
  MODIFY `questionnairePartsTableID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tb_questions`
--
ALTER TABLE `tb_questions`
  MODIFY `questionID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=256;

--
-- AUTO_INCREMENT for table `tb_questiontype`
--
ALTER TABLE `tb_questiontype`
  MODIFY `questionTypeID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `tb_user`
--
ALTER TABLE `tb_user`
  MODIFY `userID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
