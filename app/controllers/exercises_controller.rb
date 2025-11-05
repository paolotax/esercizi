class ExercisesController < ApplicationController
  def pag008
  end

  def pag010
  end

  def pag010gen
  end

  def pag022
  end

  def pag023
  end

  def pag041
  end

  def pag043
  end

  def pag050
  end

  def pag051
  end

  def pag167
  end

  def sussi_pag_5
  end

  def sussi_pag_14
  end

  def nvl_4_gr_pag008
  end

  def nvl_4_gr_pag009
  end

  def nvl_4_gr_pag014
  end

  def nvl_4_gr_pag015
  end

  def bus3_mat_p025
  end

  def bus3_mat_p026
  end

  def bus3_mat_p144
  end

  def nvi4_sto_p154
  end

  def nvi4_sto_p155
  end

  def bus3_mat_p032
  end

  def bus3_mat_p034
  end

  def bus3_mat_p035
  end

  def bus3_mat_p077
  end

  def bus2_lettgr_p096
  end

  def column_addition_grid
    operation = params[:operation]

    render partial: "shared/column_addition",
           locals: {
             operation: operation,
             show_toolbar: false,
             show_exercise: true
           },
           layout: false
  end
end
