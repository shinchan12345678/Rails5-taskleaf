class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def import
    current_user.tasks.import(params[:file])
    redirect_to tasks_path, notice: "タスクを追加しました"
  end

  def index
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result(distict: true).page(params[:page]).per(50)

    respond_to do |format|
      format.html
      format.csv{send_data @tasks.generate_csv, filename: "tasks-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
    end
  end

  def show
  end

  def new
    @task =Task.new
  end

  def confirm_new
    @task = current_user.tasks.new(task_params)
    render :new unless @task.valid?
  end

  def create
    @task = Task.new(task_params.merge(user_id: current_user.id))

    if params[:back].present?
      render :new
      return
    end

    if @task.save
      logger.debug "task #{@task.attributes.inspect}"
      redirect_to task_path(@task), notice: "タスク「#{@task.name}」を登録しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
    @task.update!(task_params)
    redirect_to tasks_path, notice: "タスク「#{task.name}」を更新しました。"
  end

  def destroy
    @task.destroy
    # redirect_to tasks_path, notice: "タスク「#{task.name}」を削除しました。"
    head :no_content
  end

  def task_logger
    @task_logger ||= Logger.new('log/task.log', 'daily')
  end

  private

  def task_params
    params.require(:task).permit(:name, :description)
  end

  def set_task
    @task =current_user.tasks.find(params[:id])
  end
end
