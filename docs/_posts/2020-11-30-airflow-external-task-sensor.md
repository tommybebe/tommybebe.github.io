---
layout: post
title: Airflow ExternalTaskSensor 사용 방법
subtitle: DAG과 DAG 사이 연결하기
keywords: airflow, Cross-DAG Dependencies, ExternalTaskSensor, ExternalTaskMarker
---


Airlflow Task의 upstream, downstream 설정을 통해 Task 실행 순서를 설정할 수 있는 것과 유사하게 DAG과 DAG 사이에서도 실행 순서를 설정할 필요가 있는 경우가 있다. 이 경우를 위해 Cross-DAG Dependencies가 제공되나, task 단위에서 사용되는 upstream/downstream의 직관적인 사용 방법에 비해 주의해야할 점들이 몇 가지 존재한다. 이 글에서는 이러한 점들에 대해 설명하고 예시 코드를 더해 복붙에 용이한 형태로 기록을 남겨두려고 한다. 

---

### 구성

아래와 같이 두 개의 DAG - [DAG_A, DAG_B]를 구성한다. DAG_A의 동작이 끝나는 Task_2가 완료되었을 때 DAG_B를 시작하여 Task_3을 실행하는 구성이다.

<iframe style="border:none" width="800" height="450" src="https://whimsical.com/embed/94gbinBtJA7y2Un95mjARD"></iframe>

- DAG_A
    - 이 경우 기존 DAG_A 구성에는 추가할 코드가 없다.
- DAG_B
    - ExternalTaskSensor Operator를 사용하여 DAG_A를 sensing한다.
    - sensor는 task의 일종으로 sensing 이후 실행할 task를 downstream 설정하여 연결한다.

### Example

- DAG_A

    ```python
    from datetime import datetime

    from airflow import DAG
    from airflow.operators.dummy_operator import DummyOperator
    from airflow.operators.python_operator import PythonOperator

    def print_execution_date(ds):
        print(ds)

    default_args = {
        'owner': 'airflow',
        'depends_on_past': False,
        'start_date': datetime(2020, 11, 30),
    }

    ds = '{{ ds }}'

    with DAG(
        dag_id='DAG_A', 
        schedule_interval='0 0 * * *',
        default_args=default_args) as dag:

        task_1 = DummyOperator(
            dag=dag,
            task_id='Task_1'
        )
        task_2 = PythonOperator(
            dag=dag,
            task_id='Task_2',
            python_callable=print_execution_date,
            op_kwargs={'ds': ds},
        )
        task_1 >> task_2
    ```

    - DAG_A 의 코드 구성은 외부의 DAG_B와 아무런 관련이 없다.
    - Task_1, Task_2 순서로 실행되며 Task_2의 끝에 execution_date을 로그에 남기는 것을 끝으로 작업을 마무리한다.
    - 작업은 매일 한번, 0시에 실행하도록 설정했다. (한국 시간 기준으로 9시)
- DAG_B

    ```python
    from datetime import datetime, timedelta

    from airflow import DAG
    from airflow.operators.sensors import ExternalTaskSensor
    from airflow.operators.python_operator import PythonOperator

    def print_execution_date(ds):
        print(ds)

    ds = '{{ ds }}'
    start_date = datetime(2020, 11, 30)

    default_args = {
        'owner': 'airflow',
        'depends_on_past': False,
        'start_date': start_date
    }

    with DAG(
        dag_id='DAG_B', 
        schedule_interval='0 0 * * *',
        default_args=default_args) as dag:

        sensor = ExternalTaskSensor(
            task_id='wait_for_task_2',
            external_dag_id='DAG_A',
            external_task_id='Task_2',
            start_date=start_date,
            execution_date_fn=lambda x: x,
            mode='reschedule',
            timeout=3600,
        )

        task_3 = PythonOperator(
            dag=dag,
            task_id='Task_3',
            python_callable=print_execution_date,
            op_kwargs={'ds': ds},
        )

        sensor >> task_3
    ```
    - DAG_B도 DAG_A와 동일한 매일 0시 실행되도록 스케쥴을 지정했다.
    - ExternalTaskSensor 설정은, 
        - external_dag_id
            - 예시의 DAG에서는 `DAG_A` 이다.
        - external_task_id
            - 예시의 코드에서는 `Task_2` 가 종료된 이후 실행되도록 설정하였다.
        - start_date
            - DAG과 무관하게 시작일자를 지정할 수 있다. DAG보다 시작일자가 뒤에 있는 경우, 앞선 job은 failed 상태로 skip된다.
        - execution_date_fn
            - sensing 대상의 execution_date을 입력한다. 예시의 경우(`lambda x: x`) execution_date 그대로 입력한 셈이다. 즉, DAG_A가 실행된 execution_date에 매치되는 execution_date에 DAG_B가 실행되어야 할 경우를 위한 예시이다.
        - mode='reschedule'
            - DAG_A의 Task_2가 완료될 때까지 up_for_reschedule 상태로 대기한다. 일정 시간마다 DAG_A의 Task_2의 상태를 확인하게 된다.
        - timeout
            - up_for_reschedule 상태를 3,600초간 유지한다. 그 이후에는 failed 상태가 된다.

- DAG_A, DAG_B 등록 이후
    1. DAG_A 실행 → 실행 완료
        ![large](/assets/2020/externalTaskSensor-dag-a-success.png)
    2. DAG_B → up_for_reschedule 상태 
        ![large](/assets/2020/externalTaskSensor-up-for-reschedule.png) *이 상태에서 일정 시간마다 DAG_A 모니터링을 시작한다.*
    3. DAG_B → DAG_A의 Task_2가 종료된 이후 queued → running → success 진행
        ![large](/assets/2020/externalTaskSensor-success.png) *모두 성공한 상태가 되었다.*
    4. DAG_B 성공 이후 로그
        ![large](/assets/2020/externalTaskSensor-success-log.png) *...Poking for DAG_A.Task_2.. 설정한 id들이 적절했는지 여기서 확인한다.*

### 주의사항

- `execution_delta` or `execution_date_fn`
    - 실행 시간의 delta 혹은 실행 일자의 지정. 두가지 sensing methods가 제공된다.
    - 둘 중 하나의 파라미터만 입력해야 한다.
- `external_dag_id` and `external_task_id` naming
    - DAG의 ID와 코드에서의 task variable의 이름이 항상 동일하게 이름 지어진다면 혼란의 여지가 없지만 그렇지 않다면 파라미터 입력 시에 주의해야 한다.

        ```python
        # ex
        task_1 = DummyOperator(
            dag=dag,
            task_id='Task_1'
        )
        ```

        - 위 예에서는 `task_1`에 task_id `Task_1` 인 DummyOperator를 생성해 할당했다.
        - `t` 와 `T` 대소문자 한글자 차이에 따라 아이디가 잘못 입력될 경우 DAG은 up_for_reschedule을 timeout 시간만큼 유지하다가 failed 상태가 된다.
- Parent DAG clear
    - DAG_A의 clear 이벤트는 DAG_B에 어떤 영향도 주지 않는다. 즉, DAG_A를 clear하는 경우 DAG_B도 clear 해야 한다.
    - 이 경우를 위해서는 DAG_A에 ExternalTaskMarker Operator를 사용해야 한다.

        ```python
        parent_task = ExternalTaskMarker(task_id="parent_task",
                                         external_dag_id="example_external_task_marker_child",
                                         external_task_id="child_task1")
        ```

        - 위와 같이 parent DAG에 child DAG의 정보를 입력해 downstream 연결하듯 사용한다.

### References

- [Cross-DAG Dependencies](https://airflow.apache.org/docs/stable/howto/operator/external.html)
- [Sensing the completion of external airflow tasks via ExternalTaskSensors](https://medium.com/@fninsiima/sensing-the-completion-of-external-airflow-tasks-827344d03142)
- [how set two DAGs in airflow using ExternalTaskSensor?](https://stackoverflow.com/questions/52003489/how-set-two-dags-in-airflow-using-externaltasksensor)
- [Airflow ExternalTaskSensor gets stuck](https://stackoverflow.com/questions/46807297/airflow-externaltasksensor-gets-stuck)