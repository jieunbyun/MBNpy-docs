inference
=========

Example setup
-------------

For the illustartion below, we set up the same example as in ``cpm.Cpm``.

.. code-block:: python

    import numpy as np
    from mbnpy import cpm, variable, inference

    # Define variables and CPMs
    varis = {}
    varis['x1'] = variable.Variable('x1', ['fail', 'surv'])
    varis['x2'] = variable.Variable('x2', ['f', 's'])
    varis['x3'] = variable.Variable('x3', ['f', 's'])

    cpms = {}
    cpms['x1'] = cpm.Cpm([varis['x1']], no_child=1, C=np.array([[0], [1]], dtype=int), p = np.array([0.1, 0.9]))
    cpms['x2'] = cpm.Cpm([varis['x2']], no_child=1, C=np.array([[0], [1]], dtype=int), p = np.array([0.2, 0.8]))

    # 'x3' is a series system of 'x1' and 'x2'
    cpms['x3'] = cpm.Cpm([varis['x3'], varis['x1'], varis['x2']], no_child=1,
                        C=np.array([[0, 0, 2], [0, 1, 0], [1, 1, 1]], dtype=int), p = np.array([1.0, 1.0, 1.0]))

Methods
-------

.. py:method:: inference.condition(cpms, cnd_vars, cnd_states)
   :noindex:

    Condition the CPMs on the given variables and states.

    :param cpms: List or dictionary of CPMs.
    :type cpms: list or dict of Cpm
    :param cnd_vars: List of variables to condition on.
    :type cnd_vars: list of Variable
    :param cnd_states: List of states to condition on.
    :type cnd_states: list of int
    :return: Conditioned CPMs.
    :rtype: list or dict of Cpm

    **Example:**

    .. code-block:: python

        cpm_x3_0 = inference.condition([cpms['x3']], [varis['x3']], [0])
        print(cpm_x3_0)

    **Output:**

    ::

        [Cpm(variables=['x3', 'x1', 'x2'],
        no_child=1,
        C=[[0 0 2]
        [0 1 0]],
        p=[[1.]
        [1.]],
        )]
    
    Notice that the previous last row of the C matrix and p vector are removed.

isinscope
~~~~~~~~~

.. py:method:: inference.isinscope(idx, cpms):
   :noindex:
    
     Check if variables are in the scope of a given set of CPMs.
    
     :param idx: list of variable names
     :type idx: list of str
     :param cpms: list or dictionary of CPMs.
     :type cpms: list or dict of Cpm
     :return: True if any of the variables are in the scope of the CPMs.
     :rtype: list of bool
    
     **Example:**
    
     .. code-block:: python
    
          isin = inference.isinscope(['x1'], cpms)
          print(isin)
    
     **Output:**
    
     ::
    
          [[ True]
           [False]
           [ True]]

variable_elim
~~~~~~~~~~~~~

.. py:method:: inference.variable_elim(cpms, var_elim, prod=True)
   :noindex:

    Perform variable elimination on the given CPMs.

    :param cpms: List or dictionary of CPMs.
    :type cpms: list or dict of Cpm
    :param var_elim: List of variables to eliminate in the order of elimination.
    :type var_elim: list of Variable
    :param prod: If True, the Cpm is returned as a product of the remaining CPMs. If False, a list of CPMs are returned after variable elimination.
    :return: Resulting CPM.
    :rtype: Cpm or list of Cpm

    **Example:**

    .. code-block:: python

        M_x3 = inference.variable_elim(cpms, [varis['x1'], varis['x2']])
        print(M_x3)

    **Output:**

    ::

        Cpm(variables=['x3'],
            no_child=1,
            C=[[0]
            [1]],
            p=[[0.28]
            [0.72]],
            )
    
    The CPM represents :math:`P(X_3) = \sum_{X_2} P(X_2) \cdot \sum_{X_1} P(X_3| X_1, X_2) \cdot P(X_1)`.

get_elimination_order
~~~~~~~~~~~~~~~~~~~~~

.. py:method:: inference.get_elimination_order(cpms)
   :noindex:

    Get the ancestry order of variables for the given cpms. The ordering priorities are (i) ancestors first, (ii) fewest parents first.

    :param cpms: List or dictionary of CPMs.
    :type cpms: list or dict of Cpm
    :return: List of Variable objects in the order of elimination.
    :rtype: list of Variable

    **Example:**

    .. code-block:: python

        ve_order = inference.get_elimination_order(cpms)
        print([v.name for v in ve_order])

    **Output:**

    ::

        ['x1', 'x2', 'x3']
    
    The output indicates that 'x1' and 'x2' should be eliminated before 'x3'.

get_inf_vars
~~~~~~~~~~~~

.. py:method:: inference.get_inf_vars(cpms, varis, ve_ord=None)
   :noindex:

    Get the list of variables in the scope of variables in ``varis``.

    :param cpms: List or dictionary of CPMs.
    :type cpms: list or dict of Cpm
    :param varis: A list of variable names or Variable objects or a single variable name or Variable object whose marginal distributions are of interest.
    :type varis: A list of str/Variable object or str/Variable object
    :param ve_ord: variable names or Variable objects in the order of elimination. If provided, the function returns the variables in the given order.
    :type ve_ord: list of str/Variable object
    :return: List of variable names in the scope of the given variables.
    :rtype: list of str

    **Example:**

    Below, an irrelevant variable 'x4' is added:

    .. code-block:: python

        varis['x4'] = variable.Variable('x4', ['f', 's'])
        cpms['x4'] = cpm.Cpm([varis['x4']], no_child=1, C = np.array([[0], [1]], dtype=int), p = np.array([0.3, 0.7]))  

    Then, the function is applied:

    .. code-block:: python

        varis_inf = inference.get_inf_vars(cpms, 'x3', ['x1', 'x2'])
        print(varis_inf)

    **Output:**

    ::

        ['x1', 'x2', 'x3']

    Notice that 'x4' is not included in the list. With the list that includes only relevant variables to obtain the marginal distribution of 'x3', one can perform variable elimination:

    .. code-block:: python

        M_x3 = inference.variable_elim([cpms[x] for x in varis_inf], [varis['x1'], varis['x2']])
        print(M_x3)

    **Output:**

    ::

        Cpm(variables=['x3'],
            no_child=1,
            C=[[0]
            [1]],
            p=[[0.28]
            [0.72]],
            )

    where the result is the same as the previous example with ``inference.variable_elim``. By eliminating irrelevant variables, one can save computational time.

prod_Msys_and_Mcomps
~~~~~~~~~~~~~~~~~~~~

.. py:method:: prod_Msys_and_Mcomps(Msys, Mcomps_list)
   :noindex:

    Compute the product of a system CPM and the list of component CPMs: :math:`P(X_{sys},X_1,...,X_n) = P(X_{sys}|X_1,...,X_n) \cdot P(X_1) \cdot ... \cdot P(X_n)`. The function is faster than ``product`` by exploiting the knowledge on which one is a system CPM and which ones are component CPMs.

    :param Msys: System CPM.
    :type Msys: Cpm
    :param Mcomps_list: List of component CPMs.
    :type Mcomps_list: list of Cpm
    :return: Product of the system and component CPMs.
    :rtype: Cpm

    **Example:**

    .. code-block:: python

        Mprod = inference.prod_Msys_and_Mcomps(cpms['x3'], [cpms['x1'], cpms['x2']])
        print(Mprod)

    **Output:**

    ::

        Cpm(variables=['x3', 'x1', 'x2'],
            no_child=3,
            C=[[0 0 2]
            [0 1 0]
            [1 1 1]],
            p=[[0.1 ]
            [0.18]
            [0.72]],
            )