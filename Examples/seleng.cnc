+( )
+(           SELECTIVE SCREENING FOR KIDNEY PATHOLOGY)
+(  )
+(  )
Pasp_2
 ( **.)
Pasp_3
 1 1 ( Male.)
 2 2 ( Female.)
Pasp_4
 0 16 (,)
 0 0 ( less then one year.)
 1 1 ( 1 year old.)
 2 4 ( ** years old.)
 5 16 ( ** years old.)
Pasp_5
 ( Home address **.)
Pasp_6
 ( School /kindergarden/ # **.)
Pasp_7
 ( Class /group/ # **.)

+(  )
+(  )
Kdis            | Kidney diseases in family:
{ 1 1 Kdis_2    |          mother
  1 1 Kdis_3    |          father
  1 1 Kdis_4    |          siblings
  1 1 Kdis_5 }  |          other relatives
sPsb1
{ 1 1 Kdis_1    | Kidney diseases in family
  0 1 Kdis
  * * Kdis_6 }  | no inform. about number of nephropathies cases
  3 3 ( Kidney pathology in patient's family.)
Kdis_6
  1 1 ( There is a case of kidney pathology in patient's family.)
sPsb2
{ 2 5  Kdis
  2 99 Kdis_6 } | number of nephropathies cases >=2
  1 2 ( There are cases of kidney pathology in patient's family.)
Kdis_2
  1 1 ( Ill mother.)
Kdis_3
  1 1 ( Ill father.)
Kdis_4
  1 1 ( Ill sibling.)
Kdis_5
  1 1 ( Ill relatives.)
Kdis_1
 1 1 (.)
Kdis_6
2 99 ( The number of nephropathies cases in patient's family - **.)
Kdis_7
 1 1 ( There are the similar nephropathies.)
Stg           | Dysembryogenesis stigmas:
{ 1 1 Stg_1    | epicanthus
  1 1 Stg_2    | eye hypertelorism
  1 1 Stg_3    | "gothic" palate
  1 1 Stg_4    | low growth of occipital hairs
  1 1 Stg_5    | earflop anomalies
  1 1 Stg_6    | teeth anomalies
  1 1 Stg_7    | eye anomalies
  1 1 Stg_8    | webbed neck
  1 1 Stg_9    | short neck
  1 1 Stg_10   | funnel breast
  1 1 Stg_11   | nipple hyperthelorism
  1 1 Stg_12   | additional nipples
  1 1 Stg_13   | wide umbilical ring
  1 1 Stg_14   | syndactylia
  1 1 Stg_15   | polydactylia
  1 1 Stg_16   | arachnodactylia
  1 1 Stg_17   | pterygodactylia
  1 1 Stg_18   | short little finger
  1 99 Stg_19 }| other stigmas
  1 19 ( Dysembryogenesis stigmas:)
Stg_1
  1 1 ( epicanthus,)
Stg_2
  1 1 ( eye hypertelorism,)
Stg_3
  1 1 ( "gothic" palate,)
Stg_4
  1 1 ( low growth of occipital hairs,)
Stg_5
  1 1 ( earflop anomalies,)
Stg_6
  1 1 ( teeth anomalies,)
Stg_7
  1 1 ( eye anomalies,)
Stg_8
  1 1 ( webbed neck,)
Stg_9
  1 1 ( short neck,)
Stg_10
  1 1 ( funnel breast,)
Stg_11
  1 1 ( nipple hypertelorism,)
Stg_12
  1 1 ( additional nipples,)
Stg_13
  1 1 ( wide umbilical ring,)
Stg_14
  1 1 ( syndactylia,)
Stg_15
  1 1 ( polydactylia,)
Stg_16
  1 1 ( arachnodactylia,)
Stg_17
  1 1 ( pterygodactylia,)
Stg_18
  1 1 ( short little finger,)
Stg
 1 19 (.)
Stg
 1 18 ( Main stigmas **.)
Stg_19
 1 9  ( Other stigmas **.)

AbdP
{ 1 1 AbdP_1   | Abdominal pain
  1 1 AbdP_2   |   epigastrium
  1 1 AbdP_3   |   subcostal area
  1 1 AbdP_4   |   lumbal area
  1 1 AbdP_5   |   iliac area
  1 1 AbdP_6 } |   pubic area
  1 1 ( Patient has abdominal pain.)
  2 6 ( Patient has pain)
AbdP_2
  1 1 ( in epigastrium,)
AbdP_3
  1 1 ( in subcostal area,)
AbdP_4
  1 1 ( in lumbal area,)
AbdP_5
  1 1 ( in iliac area,)
AbdP_6
  1 1 ( in pubic area.)
AbdP_1
 1 1 (.)
AbdPb
{ 1 1 AbdP_7    | pain connected with eating
  1 1 AbdP_8    |                with physical work
  1 1 AbdP_9}   |                with urination
 1 3 ( Pain connected )
AbdP_7
  1 1 ( with eating,)
AbdP_8
  1 1 ( with  physical work,)
AbdP_9
  1 1 ( with urination.)
AbdPb
 1 3 (.)
AbdP_10
  1 1 ( Pain accompanied with nausea and/or vomiting.)

Gpr_1
  1 1 ( Patient has transient arterial hypertension.)
  2 2 ( Patient has constant arterial hypertension.)
Gpr_2
  1 2 ( High systolic BP)
  1 1 ( moderate.)
  2 2 ( severe.)
Gpr_3
  1 2 ( High diastolic BP)
  1 1 ( moderate.)
  2 2 ( severe.)
Gpr_4
  1 1 ( High BP accompanied with headache.)
Gpr_5
  1 1 ( Retinopathy is revealed.)
Gpt_1
  1 1 ( Patient has transient)
  2 2 ( Patient has constant)
Gpt_2
  1 1 ( moderate)
  2 2 ( severe)
Gpt_1
  1 1 ( arterial hypotension.)
  2 2 ( arterial hypotension.)
Gpt_3
  1 1 ( Low BP accompanied with headache,dizziness.)

Pdo_1
  1 1 ( Laboratory examination is done.)
Anm_1
  0 0 ( Normal urinalyses.)
Anm_1
  1 1 ( Abnormal urinalyses:)
AnmL
  1 1 ( mild)
  2 2 ( moderate)
  3 3 ( severe)
  1 3 ( leucocyturia,)
AnmE
  1 1 ( mild)
  2 2 ( moderate)
  3 3 ( severe)
  1 3 ( erythrocyturia,)
AnmP
  1 1 ( mild)
  2 2 ( moderate)
  3 3 ( severe)
  1 3 ( proteinuria,)
Krs
{ 1 1 Krs_1    | crystalluria
  1 2 Krs_2    | transient or constant
  1 1 Krs_3    | calcium oxalate crystals
  1 1 Krs_4    | calcium phosphate crystals
  1 1 Krs_5    | urate crystals
  1 1 Krs_6 }  | mixed crystals
  1 1 ( crystalluria.)
  2 6 ( crystalluria)
Krs_2
  1 1 ( transient,)
  2 2 ( constant,)
Krs_3
  1 1 ( calcium oxalate crystals,)
Krs_4
  1 1 ( calcium phosphate crystals,)
Krs_5
  1 1 ( urate crystals,)
Krs_6
  1 1 ( mixed crystals.)
Anm_1
 1 1 (.)
Rnt_1
  0 0 ( US /X-ray/ examination doesn't reveal any abnormalities.)
Rnt_1
  1 1 ( US /X-ray/ examination  of urinary tract reveals)
Rnt_2
  1 1 ( pyelectasis,)
Rnt_3
  1 1 ( hydronephrosis,)
Rnt_4
  1 1 ( abnormalities of pyelocaliceal system,)
Rnt_5
  1 1 ( floating kidney,)
Rnt_6
  1 1 ( vesicoureteral reflux,)
Rnt_7
  1 1 ( kidney stones,)
Rnt_8
  1 1 ( cystic kidneys.)
Rnt_1
 1 1  (.)

STG_net_sv | There are no inf. about dysembryog. stigmas
{ * *  Stg_1    | epicanthus
  * *  Stg_2    | eye hypertelorism
  * *  Stg_3    | "gothic" palate
  * *  Stg_4    | low growth of occipital hairs
  * *  Stg_5    | earflop anomalies
  * *  Stg_6    | teeth anomalies
  * *  Stg_7    | eye anomalies
  * *  Stg_8    | webbed neck
  * *  Stg_9    | short neck
  * *  Stg_10   | funnel breast
  * *  Stg_11   | nipple hyperthelorism
  * *  Stg_12   | additional nipples
  * *  Stg_13   | wide umbilical ring
  * *  Stg_14   | syndactylia
  * *  Stg_15   | polydactylia
  * *  Stg_16   | arachnodactylia
  * *  Stg_17   | pterygodactylia
  * *  Stg_18   | short little finger
  * *  Stg_19 } | other stigmas
PRIM   |   | there are no information about:
{ 19 19 STG_net_sv | dysembryogenesis stigmas
  * * Kdis_1       | kidney diseases in family
  * * AbdP_1       | abdominal pain
  * * Gpr_1        | arterial hypertension
  * * Gpt_1        | arterial hypotension
  * * Pdo_1 }      | laboratory examination
 6 6 +(  )
 6 6 +(   Dear colleague! answer, please, at least one)
 6 6  ( question about your patient.)
 6 6 [jump(end)]
+(  )
| NamSTG - number of stigmas

Stg_19
0 10 [add(NamSTG,Stg,Stg_19)]
Stg_19
* * [add(NamSTG,Stg,0)]
NamSTG
 [add(NamSTG_vos,NamSTG,STG_net_sv)]
Stg_19
* * [add(NamSTG_vos,NamSTG_vos,8)]
Stg_neis
{ 0 4 NamSTG
  5 99 NamSTG_vos }
| 2 2
|____________________________________


PDO                | Laboratory examination was not done
{ * * Pdo_1
  0 0 Pdo_1 }

Gprt
{ 1 2 Gpr_1        | arterial hypertension
  1 2 Gpt_1 }      | arterial hypotension

GPRT_net_sv1       | no information about blood pressure
{ * * Gpr_1
  * * Gpt_1 }
GPRT_net_sv
{ 1 2 GPRT_net_sv1 | no information about blood pressure
  0 0 Gprt }       | there is no arterial hypotension or hypertension
| 2 2                    ( Pdo *)
Nef_sem           | Kidney pathology in patient's family
{ 1 1 Kdis_2    |          mother
  1 1 Kdis_3    |          father
  1 1 Kdis_4    |          siblings
  1 1 Kdis_5 }  |          other relatives
Nef_sem_isv1    | information about kidney pathology in patient's family
{ 1 1 Kdis_1
  0 1 Kdis_2
  0 99 Kdis_6 } | number of nephropathies cases
Nef_sem_isv
{ 0 0 Kdis_1         | there are no kidney pathology in patient's family
  3 3 Nef_sem_isv1 }
| 1 2
|___________Risk of kidney pathology is very high
|
Rov1
{ 1 1 Kdis_1      | kidney pathology in patient's family
  1 1 AbdP_1      | pain
  1 2 Gprt        | arterial hypotension or hypertension
  5 30 NamSTG }   | number of stigmas > 5
| 3 4                  ( Rov1 *)
Nef_sem_b3        | number of kidney pathology in family > 3
{ 3 4 Nef_sem
  3 99 Kdis_6 }   | number of nephropathies cases
| 1 2
Rov2
{ 1 1 Kdis_2       | mother has nephropathy
  1 2 Nef_sem_b3 } | number of kidney pathology in family > 3
|                      ( Rov2 *)
Rov                | Risk of kidney pathology is very high
{ 3 4 Rov1
  1 2 Rov2 }
|                      ( Rov *)
ROV
{ 1 2 Rov          | Risk of kidney pathology is very high
  1 2 PDO }        | Laboratory examination was not done
|                     ( ROV *)
  2 2 +(   CONCLUSION : The risk of kidney pathology is very high.)
  2 2  ( Urinalyses and ultrasound or X-ray examination of)
  2 2  ( urinary tract are necessary.)
|___________end Risk of kidney pathology is very high



|___________Risk of kidney pathology is rather high
Nef_sem_b2        | number of kidney pathology in family > 3
{ 2 4 Nef_sem
  2 99 Kdis_6 }   | number of nephropathies cases
Rnv3
{ 1 1 Kdis_1      | kidney pathology in family
  1 1 AbdP_1      | pain
  1 2 Gprt        | arterial hypotension or hypertension
  5 30 NamSTG }   | number of stigmas > 5
Rnv
{ 1 2 Nef_sem_b2
  2 4 Rnv3 }
RNV
{ 1 2 Rnv         | Risk of kidney pathology is rather high
  0 0 Rov
  1 2 PDO }       | Laboratory examination was not done
  3 3 +(   CONCLUSION : The risk of kidney pathology is rather high.)
  3 3  ( Urinalyses and ultrasound or X-ray examination of)
  3 3  ( urinary tract are necessary.)
  0 2  [jump(endVR)]

Nep_sv_1
{ 2 2 GPRT_net_sv
  2 2 Stg_neis
  0 0 Nef_sem_isv
  * * AbdP_1 }   | no inf. about abdominal pain
  1 4 ( Risk of nephropathy can be even VERY HIGH,if:)
GPRT_net_sv
0 1 [jump(Stg_neis)]
Gpt_1
* * ( blood pressure is low)
Gpr_1
* * ( blood pressure is high)
Stg_neis
2 2 ( number of dysembryogenesis stigmata is more then 5,)
Kdis_1
* * ( there are cases of nephropathies in family,)
* * [jump(AbdP_1)]
0 0 [jump(AbdP_1)]
Kdis_2
* * ( mother has nephropathy,)
1 1 [jump(AbdP_1)]
Kdis_6
* * ( there are 3 and more cases of nephropathies in family,)
AbdP_1
* * ( patient has abdominal pain.)
Nep_sv_1
(.)
endVR
{ * * Pasp_1 }
|_____end Risk of kidney pathology is rather high
Nep_sv_2
{ 2 2 GPRT_net_sv
  2 2 Stg_neis
  0 0 Nef_sem_isv
  * * AbdP_1 } | no inf. about abdominal pain
Rny
{ 1 1 Kdis_1  | kidney pathology in family
  5 99 NamSTG | number of dysembryogenesis stigmas >=5
  1 1 AbdP_1  | abdominal pain
  1 2 Gprt }  | arterial hypertension or hypotension
RNY
{ 0 0 Nep_sv_2
  1 4 Rny
  0 0 Rov
  0 0 Rnv
  1 2 PDO }
  5 5 +(   CONCLUSION : The risk of kidney pathology is moderate.)
  5 5  ( Urinalyses and ultrasound or X-ray examination of)
  5 5  ( urinary tract are necessary.)
RNY1
{ 1 5 Nep_sv_2
  1 4 Rny
  0 0 Rov
  0 0 Rnv
  1 2 PDO }
  5 5 +(   CONCLUSION : According to the data which you have given)
  5 5 ( risk can be estimated as moderate.Risk can be higher if:)
  0 4 [jump(RNY1)]
GPRT_net_sv
0 1 [jump(Stg_neis)]
Gpt_1
* * ( blood pressure is low)
Gpr_1
* * ( blood pressure is high)
Stg_neis
2 2 ( number of dysembryogenesis stigmata is more then 5,)
Kdis_1
* * ( there are cases of nephropathies in family,)
* * [jump(AbdP_1)]
0 0 [jump(AbdP_1)]
Kdis_2
* * ( mother has nephropathy,)
1 1 [jump(AbdP_1)]
Kdis_6
* * ( there are 3 and more cases of nephropathies in family,)
AbdP_1
* * ( patient has abdominal pain.)
RNY1
 5 5  ( Urinalyses and ultrasound or X-ray examination of)
 5 5  ( urinary tract are necessary.)
+Rnm
{ 0 4 NamSTG_vos | number of dysembryogenesis stigmas <5
  0 0 Kdis_1     | there are no: kidney pathology in family
  0 0 AbdP_1     |               abdominal pain
  0 0 Gpr_1      |               hypertension
  0 0 Gprt       |               hypotension
  1 2 PDO}
  6 6 +(   CONCLUSION : The risk of kidney pathology is minimal.)
PMS
{ 1 3 AnmL  | leucocyturia
  1 3 AnmE  | erythrocyturia
  1 3 AnmP} | proteinuria
Pat
{ 1 3 PMS           | Patho urinalusis  (1 1 Anm_1)
  1 1 Rnt_1 }
 1 2 +(   CONCLUSION : Kidney pathology is revealed.)
 1 2 ( Consultation of nephrologist is recommended.)
Dgn | Conclusion under the results of laboratory examination
{ * * Dgn_2
  * * Dgn_3
  * * Dgn_4 }
 0 0 (:)
Dgn_2
 ( ** )
Dgn_3
 (** )
Dgn_4
 (**.)
Dgn
 0 0 (.)
Pat
| 2 3 +(  )
| 2 3 ( The examination in special nephrologic clinic is recommended.)

Pam
{ 1 3 AnmL  | leucocyturia
  1 3 AnmE  | erythrocyturia
  1 3 AnmP} | proteinuria
Mtb1
{ 1 1 Pdo_1  | laboratory examination was done
  0 0 Pam
  1 1 Krs_1  | crystalluria
             | There are no:
  0 0 Rnt_1  |   urinary  tract  abnormal.  on  X-ray or ultrasound exam.
  0 0 AbdP_1 |   abdominal pain
  0 0 Gprt } |   arterial hypertension or hypotension
  6 6  +(   CONCLUSION : The dysbolism of oxalic and/or uric acid is)
 6 6  ( revealed.)
 6 6   ( Recommendations : medical control, diet, high water regimen,)
 6 6   ( medical correction of metabolic disorders.)
 6 6   ( Diet: free of broth, green salad, rhubarb, sorrel, spinate,)
 6 6   ( oranges, chocolate, products rich of ascorbic acid.)
 6 6   ( Potato-cabbage diet is recommended for 2 weeks every month.)
 6 6   ( Correction of metabolic disorders: vitamin B6, 2-3 mg/kg 24h)
 6 6   ( 1 month every quarter,)
 6 6   ( vitamins A and E 3 weeks every quarter, magnesium oxide -)
 6 6   ( 1 month every quarter. Summer - free of treatment.)
Mtb2
{ 1 1 Pdo_1   | laboratory examination was done
  0 0 Pam
  1 1 Krs_1   | crystalluria
  1 2 Gprt    | arterial hypertension or hypotension
              | There are no:
  0 0 Rnt_1   |  urinary  tract  abnormal.  on  X-ray or ultrasound exam.
  0 0 AbdP_1 }|  abdominal pain
 6 6 +(   CONCLUSION : The dysbolism of oxalic and/or uric acid)
 6 6  ( is revealed.)
 6 6  ( Recommendations : medical control,diet,high water regimen,)
 6 6  ( medical correction of metabolic disorders, consultation of)
 6 6  ( cardiologist.)
 6 6  ( Diet: free of broth, green salad, rhubarb, sorrel, spinate,)
 6 6  ( oranges, chocolate, products rich of ascorbic acid.)
 6 6  ( Potato-cabbage diet - for 2 weeks every month.)
 6 6  ( Correction of metabolic disorders: vitamin B6, 2-3 mg/kg 24h)
 6 6  ( 1 month every quarter,)
 6 6  ( vitamins A and E 3 weeks every quarter, magnesium oxide -)
 6 6  ( 1 month every quarter. Summer - free of treatment.)

Mtb3
{ 1 1 Pdo_1  | laboratory examination was done
  0 0 Pam
  1 1 AbdP_1 | abdominal pain
  1 1 Krs_1  | crystalluria
             | There are no:
  0 0 Rnt_1  |  urinary  tract  abnormal.  on  X-ray or ultrasound exam.
  0 0 Gprt } |  arterial hypertension or hypotension
 6 6 +(   CONCLUSION :The dysbolism of oxalic and/or uric acid)
 6 6  ( is revealed.)
 6 6  ( Recommendations : medical control, diet, high water regimen,)
 6 6  ( medical correction of metabolic disorders,)
 6 6  ( consultation of gastroenterologist.)
 6 6  ( Diet: free of broth, green salad, rhubarb, sorrel, spinate,)
 6 6  ( oranges, chocolate, products rich of ascorbic acid.)
 6 6  ( Potato-cabbage diet - for 2 weeks every month.)
 6 6  ( Correction of metabolic disorders: vitamin B6,2-3 mg/kg 24h)
 6 6  ( 1 month every quarter,)
 6 6  ( vitamins A and E 3 weeks every quarter, magnesium oxide -)
 6 6  ( 1 month every quarter. Summer - free of treatment.)

Mtb4
{ 1 1 Pdo_1  | laboratory examination was done
  0 0 Pam
  1 1 Krs_1  | crystalluria
  1 1 AbdP_1 | abdominal pain
  1 2 Gprt   | arterial hypertension or hypotension
  0 0 Rnt_1 }| there are no urinary tract abnormal.on X-rayor ultras. exam.
 6 6 +(   CONCLUSION : The dysbolism of oxalic and/or uric acid)
 6 6  ( is revealed.)
 6 6  ( Recommendations : medical control, diet, high water regimen,)
 6 6  ( medical correction of metabolic disorders, consultation )
 6 6  ( of cardiologist and gastroenterologist. )
 6 6  ( Diet: free of broth, green salad, rhubarb, sorrel, spinate,)
 6 6  ( oranges, chocolate, products rich of ascorbic acid.)
 6 6  ( Potato-cabbage diet - 2 weeks in every month.)
 6 6  ( Correction of metabolic disorders: vitamin B6 2-3 mg/kg 24h)
 6 6  ( 1 month every quarter,)
 6 6  ( vitamins A and E 3 weeks every quarter, magnesium oxide -)
 6 6  ( 1 month every quarter. Summer - free of treatment.)
Mtb1_1
{ 1 1 Pdo_1  | laboratory examination was done
  0 0 Pam
  1 1 Krs_1  | crystalluria
  * * Rnt_1  | urinary tract abnormal.or X-rayor ultras.exam. was not done
  0 0 AbdP_1 | there are no abdominal pain
  0 0 Gprt } |              arterial hypertension or hypotension
  6 6  +(   CONCLUSION : The dysbolism of oxalic and/or uric acid is)
 6 6  ( revealed.)
 6 6   ( Recommendations : medical control, diet, high water regimen,)
 6 6   ( medical correction of metabolic disorders.)
 6 6   ( Diet: free of broth, green salad, rhubarb, sorrel, spinate,)
 6 6   ( oranges, chocolate, products rich of ascorbic acid.)
 6 6   ( Potato-cabbage diet is recommended for 2 weeks every month.)
 6 6   ( Correction of metabolic disorders: vitamin B6, 2-3 mg/kg 24h)
 6 6   ( 1 month every quarter,)
 6 6   ( vitamins A and E 3 weeks every quarter, magnesium oxide -)
 6 6   ( 1 month every quarter. Summer - free of treatment.)
 6 6   ( Ultrasound examination of kidenys is necessary.)
Mtb2_1
{ 1 1 Pdo_1  | laboratory examination was done
  0 0 Pam
  1 1 Krs_1  | crystalluria
  * * Rnt_1  | urinary tract abnormal.or X-rayor ultras.exam. was not done
  0 0 AbdP_1 | there are no abdominal pain
  1 2 Gprt } | arterial hypertension or hypotension
 6 6 +(   CONCLUSION : The dysbolism of oxalic and/or uric acid)
 6 6  ( is revealed.)
 6 6  ( Recommendations : medical control,diet,high water regimen,)
 6 6  ( medical correction of metabolic disorders, consultation of)
 6 6  ( cardiologist.)
 6 6  ( Diet: free of broth, green salad, rhubarb, sorrel, spinate,)
 6 6  ( oranges, chocolate, products rich of ascorbic acid.)
 6 6  ( Potato-cabbage diet - for 2 weeks every month.)
 6 6  ( Correction of metabolic disorders: vitamin B 6, 2-3 mg/kg 24h)
 6 6  ( 1 month every quarter,)
 6 6  ( vitamins A and E 3 weeks every quarter, magnesium oxide -)
 6 6  ( 1 month every quarter. Summer - free of treatment.)
 6 6   ( Ultrasound examination of kidenys is necessary.)
Mtb3_1
{ 1 1 Pdo_1  | laboratory examination was done
  0 0 Pam
  1 1 Krs_1  | crystalluria
  * * Rnt_1  | urinary tract abnormal.or X-rayor ultras.exam. was not done
  1 1 AbdP_1 | abdominal pain
  0 0 Gprt } | there are no arterial hypertension or hypotension
 6 6 +(   CONCLUSION :The dysbolism of oxalic and/or uric acid)
 6 6  ( is revealed.)
 6 6  ( Recommendations : medical control, diet, high water regimen,)
 6 6  ( medical correction of metabolic disorders,)
 6 6  ( consultation of gastroenterologist.)
 6 6  ( Diet: free of broth, green salad, rhubarb, sorrel, spinate,)
 6 6  ( oranges, chocolate, products rich of ascorbic acid.)
 6 6  ( Potato-cabbage diet - for 2 weeks every month.)
 6 6  ( Correction of metabolic disorders: vitamin B6,2-3 mg/kg 24h)
 6 6  ( 1 month every quarter,)
 6 6  ( vitamins A and E 3 weeks every quarter, magnesium oxide -)
 6 6  ( 1 month every quarter. Summer - free of treatment.)
 6 6   ( Ultrasound examination of kidenys is necessary.)
Mtb4_1
{ 1 1 Pdo_1   | laboratory examination was done
  0 0 Pam
  1 1 Krs_1   | crystalluria
  * * Rnt_1   | urinary tract abnormal.or X-rayor ultras.exam. was not done
  1 1 AbdP_1  | abdominal pain
  1 2 Gprt }  | arterial hypertension or hypotension
 6 6 +(   CONCLUSION : The dysbolism of oxalic and/or uric acid)
 6 6  ( is revealed.)
 6 6  ( Recommendations : medical control, diet, high water regimen,)
 6 6  ( medical correction of metabolic disorders, consultation )
 6 6  ( of cardiologist and gastroenterologist. )
 6 6  ( Diet: free of broth, green salad, rhubarb, sorrel, spinate,)
 6 6  ( oranges, chocolate, products rich of ascorbic acid.)
 6 6  ( Potato-cabbage diet - 2 weeks in every month.)
 6 6  ( Correction of metabolic disorders: vitamin B6 2-3 mg/kg 24h)
 6 6  ( 1 month every quarter,)
 6 6  ( vitamins A and E 3 weeks every quarter, magnesium oxide -)
 6 6  ( 1 month every quarter. Summer - free of treatment.)
 6 6   ( Ultrasound examination of kidenys is necessary.)
Ygn1
{ 1 1 Pdo_1   | laboratory examination was done
  1 1 Kdis_1  | kidney pathology in family  
  0 0 AbdP_1  | there are no abdominal pain
  0 0 Gprt    | there are no arterial hypertension or hypotension
  0 0 Anm_1   | urinalyses are normal
  0 0 Rnt_1 } | there are no urinary tract abnormal.on X-rayor ultras. exam.
 6 6 +(   CONCLUSION : No signs of kidney pathology today. )
 6 6  ( Long-term observation is recommended - patient can develope)
 6 6  ( nephropathy in future.)

Ygn2
{ 1 1 Pdo_1   | laboratory examination was done
  1 1 Kdis_1  | kidney pathology in family
  0 0 AbdP_1  | there are no abdominal pain
  1 2 Gprt    | arterial hypertension or hypotension
  0 0 Anm_1   | urinalyses are normal
  0 0 Rnt_1 }| there are no urinary tract abnormal.on X-rayor ultras. exam.
 6 6 +(   CONCLUSION : No signs of kidney pathology today.)
 6 6  ( Long-term observation is recommended - patient can develope)
 6 6  ( nephropathy in future.)
 6 6  ( Consultation of cardiologist is recommended because of)
 6 6  ( changed blood pressure)

Ygn3
{ 1 1 Pdo_1  | laboratory examination was done
  1 1 Kdis_1 | kidney pathology in family
  1 1 AbdP_1 | abdominal pain
  0 0 Gprt   | there is no arterial hypotension or hypertension
  0 0 Anm_1  | urinalyses are normal
  0 0 Rnt_1 }| there are no urinary tract abnormal.on X-rayor ultras. exam.
 6 6 +(   CONCLUSION : No signs of kidney pathology today.)
 6 6  ( Long-term observation is recommended - patient can develope)
 6 6  ( nephropathy in future.)
 6 6 ( Consultation of gastroenterologist is recommended)
 6 6 ( because of abdominal pain)
Ygn4
{ 1 1 Pdo_1   | laboratory examination was done
  1 1 Kdis_1  | kidney pathology in family
  1 1 AbdP_1  | abdominal pain
  1 2 Gprt    | arterial hypertension or hypotension
  0 0 Anm_1   | urinalyses are normal 
  0 0 Rnt_1 } | there are no urinary tract abnormal.on X-rayor ultras. exam.
 6 6 +(   CONCLUSION : No signs of kidney pathology today.)
 6 6  ( Long-term observation is recommended - patient can develope)
 6 6  ( nephropathy in future.)
 6 6  ( Consultation of cardiologist and gastroenterologist)
 6 6  ( is recommended because of changed blood pressure and)
 6 6  ( abdominal pain.)

Dnn1
{ 1 1 Pdo_1   | laboratory examination was done
  0 0 Kdis_1  | there is no kidney pathology in family 
  0 0 AbdP_1  | there is no abdominal pain
  0 0 Gprt    | there is no arterial hypotension or hypertension
  0 0 Anm_1   | urinalyses are normal
  0 0 Rnt_1 } | there are no urinary tract abnormal.on X-rayor ultras. exam.
 6 6 +(   CONCLUSION : No signs of kidney pathology today.)
 6 6  ( No special indications to additional examination and)
 6 6  ( medical control.)

Dnn2
{ 1 1 Pdo_1   | laboratory examination was done
  0 0 Kdis_1  | there are no kidney pathology in family
  1 1 AbdP_1  | abdominal pain
  0 0 Gprt    | there is no arterial hypotension or hypertension
  0 0 Anm_1   | urinalyses are normal
  0 0 Rnt_1 } | there are no urinary tract abnormal.on X-rayor ultras. exam.
 6 6 +(   CONCLUSION : No signs of kidney pathology today.)
 6 6 ( Consultation of gastroenterologist is recommended)
 6 6 ( because of abdominal pain.)
Dnn3
{ 1 1 Pdo_1  | laboratory examination was done
  0 0 Kdis_1 | there are no kidney pathology in family
  0 0 AbdP_1 | there are no abdominal pain
  1 2 Gprt   | arterial hypertension or hypotension
  0 0 Anm_1  | urinalyses are normal 
  0 0 Rnt_1 } | there are no urinary tract abnormal.on X-rayor ultras. exam.
 6 6 +(   CONCLUSION : No signs of kidney pathology today.)
 6 6 ( Consultation of cardiologist and/or neurologist is)
 6 6 ( recommended because of)
 6 6 ( changed blood pressure.)
Dnn4
{ 1 1 Pdo_1   | laboratory examination was done
  0 0 Kdis_1  | there are no kidney pathology in family
  1 1 AbdP_1  | abdominal pain
  1 2 Gprt    | arterial hypertension or hypotension
  0 0 Anm_1   | urinalyses are normal
  0 0 Rnt_1 } | there are no urinary tract abnormal.on X-rayor ultras. exam.
 6 6 +(   CONCLUSION : No signs of kidney pathology today.)
 6 6  ( Consultation of cardiologist and gastroenterologist)
 6 6  ( is recommended because of changed blood pressure and)
 6 6  ( abdominal pain.)
Prm
{ 2 2 ROV        | This syndrome defines,
  3 3 RNV        | if at least one conclusion is generated
  4 4 RNY
  6 6 Rnm
  2 3 Pat
  6 6 Mtb1
  6 6 Mtb2
  6 6 Mtb3
  6 6 Mtb4
  6 6 Ygn1
  6 6 Ygn2
  6 6 Ygn3
  6 6 Ygn4
  6 6 Dnn1
  6 6 Dnn2
  6 6 Dnn3
  6 6 Dnn4 }
PZb
{ 0 1 Kdis_2      | Check if an answer exists in the group of
  0 1 Kdis_3      | questions about hereditary diseases
  0 1 Kdis_4      | in the patient's family
  0 1 Kdis_5
  0 99 Kdis_6
  0 1 Kdis_7 }
PZB
{ 1 1 Kdis_1      | There is nephropathies in family, but there no
  0 0 Prm        | information who has them and about their character
  0 0 PZb }
ABd
{ 1 1 AbdP_2      | Check if there exists an answer in the group
  1 1 AbdP_3      | of questions about abdominal pain
  1 1 AbdP_4
  1 1 AbdP_5
  1 1 AbdP_6
  1 1 AbdP_7
  1 1 AbdP_8
  1 1 AbdP_9
  1 1 AbdP_10 }
ABD
{ 1 1 AbdP_1     | The patient has abdominal pain but is there no
  0 0 Prm        | information about it's character
  0 0 ABd }
GPr
{ 0 2 Gpr_2      | Check if an answer exists in the group of
  0 2 Gpr_3      | questions about hypertension
  0 1 Gpr_4
  0 1 Gpr_5 }
GPR
{ 1 2 Gpr_1   | The patient has arterial hypertension but there is no
  0 0 Prm     | information about it's character
  0 0 GPr }
GPt
{ 0 2 Gpt_2      | Check the hypotension group
  0 1 Gpt_3 }
GPT
{ 1 2 Gpt_1   | The patient has arterial hypotension but there is no
  0 0 Prm     | information about it's character
  0 0 GPt }
anm
{ 0 1 Anm_1 }
ANM
{ 1 1 Pdo_1
  0 0 anm }
ANm
{ 1 1 Pdo_1      | Check the presence of pathologic urinalyses
  1 1 Anm_1      | Abnormal urinalyses (including crystalluria)
  0 0 Prm }
PdoAnm
{ 0 3 AnmL      | Check the group of questions on pathologic
  0 3 AnmE      | urinalyses without crystalluria
  0 3 AnmP }
PdoANM
{ 3 3 ANm   |  The patient has pathologic urinalyses but there is no
  0 0 Prm   |  information about character of changes
  0 0 PdoAnm }
krs
{ 0 1 Krs_1 }
KRS
{ 1 1 Anm_1 | Abnormal urinalyses (including crystalluria)
  0 0 krs }
KRs        | Check crystalluria
{ 1 1 Pdo_1      
  1 1 Krs_1
  0 0 Prm }
PdoKrs     | Check the character of crystalluria
{ 1 2 Krs_2  | transient -1  constant -2
  0 1 Krs_3  | calcium oxalate crystals   -1
  0 1 Krs_4  | calcium phosphate crystals -1
  0 1 Krs_5  | urate crystals             -1
  0 1 Krs_6 }| mixed crystals
PdoKRS
{ 3 3 KRs        |  The patient has crystalluria bit there no
  0 0 Prm        |  information about it's character
  0 0 PdoKrs }
rnt
{ 0 1 Rnt_1 }
RNT
{ 1 1 Pdo_1
  0 0 rnt }
RNt
{ 1 1 Pdo_1
  1 1 Rnt_1
  0 0 Prm }
PdoRnt
{ 0 1 Rnt_2      | Check the group of questions on US or X-ray
  0 1 Rnt_3      | kidney pathology
  0 1 Rnt_4
  0 1 Rnt_5
  0 1 Rnt_6
  0 1 Rnt_7
  0 1 Rnt_8 }
PdoRNT
{ 3 3 RNt        |  The patient has X-ray or US changes but
  0 0 Prm        |  there no information about their character
  0 0 PdoRnt }
PRM
{ 3 3 PZB
  3 3 ABD
  3 3 GPR
  3 3 GPT
  2 2 ANM
  3 3 PdoANM
  2 2 KRS
  3 3 PdoKRS
  2 2 RNT
  3 3 PdoRNT }
 1 10 +(  )
 1 10 +(   Colleague ! Answer,please,)
PZB
 3 3 +( who in patient's family has kidney pathology,)
ABD
 3 3 +( what is the character of abdominal pain,)
GPR
 3 3 +( what is the specificity of patient's hypertension,)
GPT
 3 3 +( what is the specificity of patient's hypotension,)
ANM
 2 2 +( are the patient's urinalyses normal or not,)
PdoANM
 3 3 +( what is the specificity of patient's urinalyses,)
KRS
 2 2 +( does the patient have crystalluria,)
PdoKRS
 3 3 +( what is the specificity of patient's crystalluria,)
RNT
 2 2 +( does the patient have abnormalities revealed on)
 2 2  ( X-ray or ultrasound examination of urinary tract,)
PdoRNT
 3 3 +( what abnormalities are revealed on X-ray or )
 3 3  (ultrasound examination of patient)
PRM
 1 10 (.)
Pzb
{ 0 1 Kdis_1 }
Abd
{ 0 1 AbdP_1 }
| sGpr
| { 0 1 Gpr_1 }
| sGpt
| { 0 1 Gpt_1 }
AbHyper
{ * *  Gpr_1
  0 0  Gpt_1   }
AbHypo
{ * *  Gpt_1
  0 0  Gpr_1   }
AbBP
{ * *  Gpt_1
  * *  Gpr_1   }
Pdo
{ 0 1 Pdo_1 }
STG_sv
{ 1 19 STG_net_sv
  5 99 NamSTG_vos }
Prim
{ 0 0 Pzb
  2 2 STG_sv
  0 0 Abd
|  0 0 sGpr
|  0 0 sGpt
  2 2 AbHyper
  2 2 AbHypo
  2 2 AbBP
  0 0 Pdo }
PRim
{ 0 0 Prm
  1 5 Prim }
 2 2 +(  )
 2 2 +(   Colleague! It may be possible to give you an)
 2 2  ( advice if you answer the questions which you have)
 2 2  ( skipped, about:)
PRIm
{ 1 17 Prm
  1 6 Prim }
 2 2 +(  )
 2 2 +(   Colleague! Our recommendations may change,)
 2 2  ( if you answer the questions which you have)
 2 2  ( skipped, about:)
Pzb
 0 0 +( the presence of kidney pathology in patient's family,)
STG_sv
 2 2 +( the dysembryogenesis stigmas of the patient,)
Abd
 0 0 +( the presence and specificity of abdominal pain,)
AbHyper
 2 2 +( the presence and specificity of arterial hypertension,)
| sGpt
AbHypo
 2 2 +( the presence and specificity of arterial hypotension,)
AbBP
 2 2 +( the presence and specificity of arterial hyper/hypotension,)
Pdo
 0 0 +( the presence and result of laboratory examination,)
PRim
 2 2 (.)
PRIm
 2 2 (.)
end
