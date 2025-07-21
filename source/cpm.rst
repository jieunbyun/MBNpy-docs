cpm
===

Class
-----

.. py:class:: Cpm

    A class for conditional probability matrices (CPMs) of MBN.

    :param variables: List of Variables in the scope of the distribution.
    :type variables: list
    :param no_child: Number of child nodes.
    :type no_child: int
    :param C: Event matrix specifying the state of each instance.
    :type C: 2D numpy.ndarray
    :param p: Probability vector defining the corresponding probabilities.
    :type p: 1D numpy.ndarray
    :param Cs: Event matrix of sampled instances.
    :type Cs: 2D numpy.ndarray
    :param q: Sampling probability vector of sampled instances.
    :type q: 1D numpy.ndarray
    :param ps: Current probability vector of sampled instances (q and ps are the same for Monte Carlo simulation, but are not for other sampling techniques e.g. importance sampling).
    :type ps: 1D numpy.ndarray
    :param sample_idx: Index of the sampled instance. When samples are first generated, the index starts from 0 to the number of instances. This vector is necessary since a sample can become two instances during inference and different samples cannot be computed together.
    :type sample_idx: 1D numpy.ndarray

.. note::

    ``Cs``, ``q``, ``ps``, and ``sample_idx`` are only necessary when samples are used.

Example Usage
-------------

.. code-block:: python

    from mbnpy import variable, cpm
    import numpy as np

    # First define the variables
    varis = {}
    varis['x1'] = variable.Variable('x1', ['fail', 'surv'])
    varis['x2'] = variable.Variable('x2', ['f', 's'])
    varis['x3'] = variable.Variable('x3', ['f', 's'])

    # Define the CPMs
    cpms = {}
    cpms['x1'] = cpm.Cpm([varis['x1']], no_child=1, C=np.array([[0], [1]], dtype=int), p = np.array([0.1, 0.9]))
    cpms['x2'] = cpm.Cpm([varis['x2']], no_child=1, C=np.array([[0], [1]], dtype=int), p = np.array([0.2, 0.8]))

    # 'x3' is a series system of 'x1' and 'x2'
    cpms['x3'] = cpm.Cpm([varis['x3'], varis['x1'], varis['x2']], no_child=1,
                        C=np.array([[0, 0, 2], [0, 1, 0], [1, 1, 1]], dtype=int), p = np.array([1.0, 1.0, 1.0]))

Methods
-------

product (1)
~~~~~~~~~~~

.. py:method:: Cpm.product(self, M)
   :noindex:

    Compute the product of the CPM with another CPM.

    :param M: Another CPM.
    :type M: Cpm
    :return: The product of the two CPMs.
    :rtype: Cpm

    **Example:**
    One can perform :math:`P(X_3|X_1,X_2) \cdot P(X_1)` as follows:

    .. code-block:: python

        cpm_x3_x1 = cpms['x3'].product(cpms['x1'])
        print(cpm_x3_x1)
    
    **Output:**
    
    ::

        Cpm(variables=['x3', 'x1', 'x2'],
            no_child=2,
            C=[[0 0 2]
            [0 1 0]
            [1 1 1]],
            p=[[0.1]
            [0.9]
            [0.9]],
            )

    Notice that ``no_child`` is updated to 2 as now ``Mnew`` represents :math:`P(X_3,X_1|X_2)`.

get_subset
~~~~~~~~~~

.. py:method:: Cpm.get_subset(self, row_idx, flag=True, isC=True)
   :noindex:

    Get a new CPM with a subset of rows from event matrix and probability vector.

    :param row_idx: List of row indices to be selected.
    :type row_idx: list
    :param flag: If True, the subset is selected. If False, the subset is removed.
    :type flag: bool
    :param isC: If True, the subset is obtained from ``C`` and ``p``. If False, the subset is obtained from ``Cs``, ``q``, ``ps``, and ``sample_idx``.
    :type isC: bool
    :return: A new CPM with the subset of rows.
    :rtype: Cpm

    **Example:**

    .. code-block:: python

        Mnew = cpm_x3_x1.get_subset([0,2])
        print(Mnew)
    
    **Output:**
    
    ::

        Cpm(variables=['x3', 'x1', 'x2'],
            no_child=2,
            C=[[0 0 2]
            [1 1 1]],
            p=[[0.1]
            [0.9]],
            )

iscompatible (1)
~~~~~~~~~~~~~~~~

.. py:method:: Cpm.iscompatible(self, M, composite_state=True)
   :noindex:

    Check if two CPMs are compatible.

    :param M: Another CPM. Must include a single row in either ``C`` or ``Cs``.
    :type M: Cpm
    :param composite_state: If True, the function considers compatibility between basic states and composite states. If False, the function considers strict compatibility that two states are compatible when they have the same index.
    :type composite_state: bool
    :return: For each row of ``C`` or ``Cs``, a boolean value indicating whether the row is compatible with the corresponding row in the other CPM.
    :rtype: a list of bool

    **Example:**

    The code below finds the rows of ``cpms['x3']`` that indicate ``X3``'s failure state: 

    .. code-block:: python

        M1 = cpm.Cpm([varis['x3']], no_child=1, C=np.array([[0]], dtype=int))
        is_cmp = cpms['x3'].iscompatible(M1)
        print(is_cmp)
    
    **Output:**
    
    ::

        [True, True, False]

sum
~~~

.. py:method:: Cpm.sum(self, variables, flag=True)
   :noindex:

    Sum out the variables in the CPM.

    :param variables: List of variables to be summed out.
    :type variables: list of Variable
    :param flag: If True, the variables are summed out. If False, the variables are kept and the other variables are summed out.
    :type flag: bool
    :return: A new CPM with the variables summed out.
    :rtype: Cpm

    **Example:**

    The code below sums out ``X1`` from :math:`P(X_3,X_1|X_2)`, i.e. :math:`\sum_{X_1} P(X_3,X_1|X_2) = P(X_3|X_2)`:

    .. code-block:: python

        Mnew = cpm_x3_x1.sum([varis['x1']])
        print(Mnew)
    
    **Output:**
    
    ::

        Cpm(variables=['x3', 'x2'],
            no_child=1,
            C=[[0 2]
            [0 0]
            [1 1]],
            p=[[0.1]
            [0.9]
            [0.9]],
        )

sort
~~~~

.. py:method:: cpm.sort(self)
   :noindex:

    Sort the CPM based on ``C`` and ``sample_idx``.

    :return: A new CPM with the rows sorted.
    :rtype: Cpm

    **Example:**

    The code below sorts the rows of :math:`P(X_3|X_2)` from the result above:

    .. code-block:: python

        cpm_x3_x2.sort()
        print(cpm_x3_x2)
    
    **Output:**
    
    ::

        Cpm(variables=['x3', 'x2'],
            no_child=1,
            C=[[0 0]
            [0 2]
            [1 1]],
            p=[[0.9]
            [0.1]
            [0.9]],
            )


iscompatible (2)
~~~~~~~~~~~~~~~~

.. py:method:: cpm.iscompatible(C, variables, check_vars, check_states, composite_state=True)

    Check if a ``C`` defined over ``variables`` is compatible with ``check_states`` of ``check_vars``.

    :param C: Event matrix of the CPM.
    :type C: 2D numpy.ndarray
    :param variables: List of variables in the scope of ``C``.
    :type variables: list
    :param check_vars: List of variables to be checked for compatibility.
    :type check_vars: list
    :param check_states: List of states to be checked for compatibility.
    :type check_states: list
    :param composite_state: If True, the function considers compatibility between basic states and composite states. If False, the function considers strict compatibility that two states are compatible when they have the same index.
    :type composite_state: bool
    :return: For each row of ``C``, a boolean value indicating whether the row is compatible with the given variables and states.
    :rtype: a list of bool

    **Example:**

    The code below finds the rows of ``cpms['x3']`` that indicate ``X3``'s failure state: 

    .. code-block:: python

        is_cmp = cpm.iscompatible(cpms['x3'].C, cpms['x3'].variables, [varis['x3']], [0], composite_state=True)

        print(is_cmp)
    
    **Output:**
    
    ::

        [True, True, False]

product (2)
~~~~~~~~~~~

.. py:method:: cpm.product(cpms):

    Mutiply a list or dictionary of CPMs.

    :param cpms: List of CPMs.
    :type cpms: list or dictionary of Cpm
    :return: The product of the CPMs.
    :rtype: Cpm

    **Example:**
    
    Code below multiplies :math:`P(X_3|X_1,X_2)`, :math:`P(X_1)`, and :math:`P(X_2)`, i.e. :math:`P(X_3,X_1,X_2) = P(X_3|X_1,X_2) \cdot P(X_1) \cdot P(X_2)`:

    .. code-block:: python

        Mprod = cpm.product(cpms)
        print(Mprod)

    **Output:**

    ::

        Cpm(variables=['x1', 'x2', 'x3'],
            no_child=3,
            C=[[0 0 0]
            [0 1 0]
            [1 0 0]
            [1 1 1]],
            p=[[0.02]
            [0.08]
            [0.18]
            [0.72]],
            )

get_means
~~~~~~~~~~

.. py:method:: Cpm.get_means(self, names)
   :noindex:

    Compute the expected (mean) values of the specified variables under the CPM’s probability distribution.

    :param names: A list of variable names or ``Variable`` objects to compute the means for.
    :type names: list
    :return: A list of mean values corresponding to the input variables (in the same order).
    :rtype: list

    **Example:**

    .. code-block:: python

        varis = {
            'x1': variable.Variable('x1', ['fail', 'surv']),
            'x2': variable.Variable('x2', [0, 2]),
        }
        M1 = cpm.Cpm(variables=['x1', 'x2'], no_child=2, C=[[0, 0], [0, 1], [1, 0], [0, 0]], p=[0.1, 0.2, 0.3, 0.4])
        means = M1.get_means(['x1', 'x2'])
        print(means)

    **Output:**

    ::

        [0.42, 1.68]

    If a variable is non-numeric, the mean is computed based on its encoded index values (e.g. 0 or 1).
    If the variable has numeric values (e.g. [0.0, 2.0]), the true expected value is calculated as a weighted sum.